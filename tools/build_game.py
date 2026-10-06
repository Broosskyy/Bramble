#!/usr/bin/env python3
"""Build validated Web and signed Android test exports from one Godot project."""
from __future__ import annotations

import argparse
import configparser
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSION = "4.7.2"


def run(label: str, command: list[str], env: dict[str, str]) -> str:
    print(f"[{label}]", flush=True)
    result = subprocess.run(command, cwd=ROOT, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            errors="replace", timeout=1200)
    log = ROOT / "build/logs" / f"{label}.log"
    log.parent.mkdir(parents=True, exist_ok=True)
    log.write_text(result.stdout, encoding="utf-8")
    errors = re.search(r"(?:^|\n)(?:SCRIPT ERROR:|ERROR:|Parse Error:)", result.stdout)
    if result.returncode or errors:
        print(result.stdout[-12000:])
        raise RuntimeError(f"{label} failed (exit {result.returncode}); see {log}")
    print(f"  PASS — {log.relative_to(ROOT)}", flush=True)
    return result.stdout


def presets() -> configparser.ConfigParser:
    config = configparser.ConfigParser(interpolation=None, strict=False)
    config.optionxform = str
    config.read(ROOT / "export_presets.cfg", encoding="utf-8")
    android = next(s for s in config.sections() if config[s].get("name") == '"Android"')
    web = next(s for s in config.sections() if config[s].get("name") == '"Web Mobile Gate"')
    for key in ("export_filter", "include_filter", "exclude_filter", "custom_features"):
        if config[android][key] != config[web][key]:
            raise RuntimeError(f"Web/Android content parity mismatch: {key}")
    return config


def configure_android(args: argparse.Namespace, env: dict[str, str]) -> Path:
    sdk_value = args.android_sdk or env.get("ANDROID_HOME") or env.get("ANDROID_SDK_ROOT")
    java_value = args.java_sdk or env.get("JAVA_HOME")
    # Editor-configured exports also work without command-line SDK arguments.
    if sys.platform == "win32":
        config_dir = Path(env.get("APPDATA", str(Path.home() / "AppData/Roaming"))) / "Godot"
    elif sys.platform == "darwin":
        config_dir = Path.home() / "Library/Application Support/Godot"
    else:
        config_dir = Path(env.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "godot"
    settings = config_dir / "editor_settings-4.7.tres"
    text = settings.read_text(encoding="utf-8") if settings.exists() else ""
    def existing(key: str) -> str | None:
        match = re.search(rf"^{re.escape(key)}\s*=\s*(\".*\")$", text, re.M)
        return json.loads(match.group(1)) if match else None
    sdk_value = sdk_value or existing("export/android/android_sdk_path")
    java_value = java_value or existing("export/android/java_sdk_path")
    java_exe = shutil.which("java")
    if not java_value and java_exe:
        java_value = str(Path(java_exe).resolve().parents[1])
    if not sdk_value or not java_value:
        raise RuntimeError("Android needs Java 17 and Android SDK. Set JAVA_HOME and ANDROID_HOME, "
                           "or pass --java-sdk and --android-sdk. See docs/workflow/BUILD_WEB_ANDROID.md")
    sdk, java = Path(sdk_value).resolve(), Path(java_value).resolve()
    suffix = ".exe" if sys.platform == "win32" else ""
    for file in (sdk / "platform-tools" / f"adb{suffix}",
                 sdk / "build-tools/36.0.0" / ("apksigner.bat" if suffix else "apksigner"),
                 sdk / "platforms/android-36/android.jar", java / "bin" / f"keytool{suffix}"):
        if not file.is_file():
            raise RuntimeError(f"Missing Android build tool: {file}")
    key = Path(args.debug_keystore or env.get("GODOT_ANDROID_KEYSTORE_DEBUG_PATH")
               or str(Path.home() / ".cache/bramble/debug.keystore")).resolve()
    alias = env.get("GODOT_ANDROID_KEYSTORE_DEBUG_USER", "androiddebugkey")
    password = env.get("GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD", "android")
    if not key.exists():
        key.parent.mkdir(parents=True, exist_ok=True)
        run("debug-keystore", [str(java / "bin" / f"keytool{suffix}"), "-genkeypair",
            "-keystore", str(key), "-storepass", password, "-keypass", password,
            "-alias", alias, "-keyalg", "RSA", "-keysize", "2048", "-validity", "10000",
            "-dname", "CN=Bramble Test,O=Bramble,C=DE", "-storetype", "JKS"], env)
        if sys.platform != "win32":
            key.chmod(0o600)
    # Use isolated editor settings on Linux; never replace the user's desktop preferences.
    if sys.platform.startswith("linux"):
        env["XDG_CONFIG_HOME"] = str(ROOT / ".tools/build-config")
        settings = Path(env["XDG_CONFIG_HOME"]) / "godot/editor_settings-4.7.tres"
        text = '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
    elif not text:
        text = '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
    for name, value in {"java_sdk_path": str(java), "android_sdk_path": str(sdk),
                        "debug_keystore": str(key), "debug_keystore_user": alias,
                        "debug_keystore_pass": password}.items():
        line = f"export/android/{name} = {json.dumps(value.replace(chr(92), '/'))}"
        pattern = rf"^export/android/{name}\s*=.*$"
        text = re.sub(pattern, lambda _: line, text, flags=re.M) if re.search(pattern, text, re.M) else text + line + "\n"
    settings.parent.mkdir(parents=True, exist_ok=True)
    settings.write_text(text, encoding="utf-8")
    env["JAVA_HOME"] = str(java)
    env["PATH"] = str(java / "bin") + os.pathsep + env.get("PATH", "")
    env["GODOT_ANDROID_KEYSTORE_DEBUG_PATH"] = str(key)
    env["GODOT_ANDROID_KEYSTORE_DEBUG_USER"] = alias
    env["GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD"] = password
    return sdk


def audit_apk(path: Path, sdk: Path, env: dict[str, str]) -> None:
    with zipfile.ZipFile(path) as archive:
        bad = archive.testzip()
        names = set(archive.namelist())
        required = {"AndroidManifest.xml", "classes.dex", "assets/project.binary",
                    "lib/arm64-v8a/libgodot_android.so", "lib/armeabi-v7a/libgodot_android.so"}
        if bad or required - names:
            raise RuntimeError(f"APK content audit failed: corrupt={bad}, missing={sorted(required - names)}")
        if any(name.startswith(("assets/artifacts/", "assets/web_reference_v23_28/",
                                "assets/assets/game/references/")) for name in names):
            raise RuntimeError("APK contains excluded build evidence/source references")
    tools = sdk / "build-tools/36.0.0"
    signer = tools / ("apksigner.bat" if sys.platform == "win32" else "apksigner")
    run("apk-signature", [str(signer), "verify", "--verbose", str(path)], env)
    aapt = tools / ("aapt.exe" if sys.platform == "win32" else "aapt")
    metadata = run("apk-manifest", [str(aapt), "dump", "badging", str(path)], env)
    tree = run("apk-launcher", [str(aapt), "dump", "xmltree", str(path), "AndroidManifest.xml"], env)
    # Godot 4.7 launches through an exported activity-alias, which aapt's
    # legacy badging output does not report as a launchable-activity.
    lines = tree.splitlines()
    launcher = False
    for i, line in enumerate(lines):
        if not re.match(r"\s*E: activity(?:-alias)? \(", line):
            continue
        indent = len(line) - len(line.lstrip())
        block: list[str] = []
        for child in lines[i + 1:]:
            if child.strip() and len(child) - len(child.lstrip()) <= indent:
                break
            block.append(child)
        node = "\n".join(block)
        if ("android.intent.action.MAIN" in node and "android.intent.category.LAUNCHER" in node
                and re.search(r"android:exported.*0xffffffff", node)):
            launcher = True
            break
    if "package: name='com.broosskyy.bramble'" not in metadata or not launcher:
        raise RuntimeError("APK has incorrect package name or no launchable activity")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", choices=("all", "web", "android"), default="all")
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
    parser.add_argument("--android-sdk")
    parser.add_argument("--java-sdk")
    parser.add_argument("--debug-keystore")
    args = parser.parse_args()
    env = dict(os.environ)
    godot = shutil.which(args.godot) or str(Path(args.godot).resolve())
    version = subprocess.check_output([godot, "--version"], text=True).strip()
    if not version.startswith(VERSION + ".stable"):
        raise RuntimeError(f"Godot {VERSION} stable required; found {version}")
    presets()
    manifest = ROOT / "build/build-manifest.json"
    manifest.unlink(missing_ok=True)  # A failed rebuild must not leave an old success report.
    sdk = configure_android(args, env) if args.target != "web" else None
    command = [godot, "--headless", "--path", str(ROOT)]
    run("source-mobile", [sys.executable, "tools/validate_web_mobile_source.py"], env)
    run("import", command + ["--editor", "--quit"], env)
    run("mobile-contract", command + ["--script", "tools/web_mobile_gate_test.gd"], env)
    smoke = run("production-smoke", command + ["--", "--smoke-test"], env)
    if "BRAMBLE smoke test: PASS" not in smoke:
        raise RuntimeError("Production smoke did not report success")
    artifacts: list[Path] = []
    if args.target != "android":
        web = ROOT / "build/web"
        web.mkdir(parents=True, exist_ok=True)
        for file in web.iterdir():
            if file.is_file():
                file.unlink()
        run("export-web", command + ["--export-release", "Web Mobile Gate", str(web / "index.html")], env)
        run("audit-web", [sys.executable, "tools/validate_web_export.py", "--build-dir", str(web)], env)
        packed = run("exported-web-smoke", [godot, "--headless", "--main-pack", str(web / "index.pck"),
                                             "--", "--smoke-test"], env)
        if "BRAMBLE smoke test: PASS" not in packed:
            raise RuntimeError("Exported Web PCK smoke did not report success")
        bundle = ROOT / "build/bramble-web.zip"
        with zipfile.ZipFile(bundle, "w", zipfile.ZIP_DEFLATED) as archive:
            for file in sorted(web.iterdir()):
                if file.is_file():
                    archive.write(file, file.name)
        artifacts.append(bundle)
    if args.target != "web":
        apk = ROOT / "build/android/Bramble.apk"
        apk.parent.mkdir(parents=True, exist_ok=True)
        apk.unlink(missing_ok=True)
        run("export-android", command + ["--export-debug", "Android", str(apk)], env)
        assert sdk is not None
        audit_apk(apk, sdk, env)
        artifacts.append(apk)
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    dirty = bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True).strip())
    result = {"status": "PASS", "godot": version, "source_commit": revision,
              "source_modified": dirty, "target": args.target,
              "main_scene": "res://scenes/main.tscn", "android_signing": "debug/test" if sdk else None,
              "device_validation": "pending", "artifacts": [
        {"path": str(p.relative_to(ROOT)), "bytes": p.stat().st_size,
         "sha256": hashlib.file_digest(p.open("rb"), "sha256").hexdigest()} for p in artifacts]}
    manifest.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, OSError, ValueError, StopIteration, subprocess.SubprocessError) as error:
        print(f"BUILD=FAIL: {error}", file=sys.stderr)
        sys.exit(1)
