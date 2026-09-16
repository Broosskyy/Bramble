#!/usr/bin/env python3
"""
BRAMBLE delivery workflow — runtime QA, live capture, git commit/push.

Usage:
  python tools/bramble_delivery.py --milestone m02.2 --message "feat(m02.2): visual production pass"
  python tools/bramble_delivery.py --capture-only
  python tools/bramble_delivery.py --no-push
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GODOT_DEFAULT = Path(
    os.environ.get(
        "BRAMBLE_GODOT",
        r"C:\Users\manue\Downloads\Godot-4.7.2\editor\Godot_v4.7.2-stable_win64.exe",
    )
)
MAIN_SCENE = "res://scenes/main.tscn"
LIVE_DIR = ROOT / "artifacts" / "live"
MIN_PNG_BYTES = 20_000


class DeliveryError(Exception):
    pass


def run(cmd: list[str], *, cwd: Path = ROOT, check: bool = True, timeout: int | None = None) -> subprocess.CompletedProcess:
    print(f"$ {' '.join(cmd)}")
    result = subprocess.run(
        cmd,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        timeout=timeout,
    )
    if check and result.returncode != 0:
        raise DeliveryError(
            f"Command failed ({result.returncode}): {' '.join(cmd)}\n"
            f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}"
        )
    return result


def godot_bin() -> Path:
    if not GODOT_DEFAULT.exists():
        raise DeliveryError(f"Godot not found: {GODOT_DEFAULT}")
    return GODOT_DEFAULT


def read_project_main_scene() -> str:
    text = (ROOT / "project.godot").read_text(encoding="utf-8")
    match = re.search(r'run/main_scene="([^"]+)"', text)
    return match.group(1) if match else MAIN_SCENE


def run_godot(extra_args: list[str], timeout: int = 600) -> subprocess.CompletedProcess:
    cmd = [
        str(godot_bin()),
        "--path",
        str(ROOT),
        read_project_main_scene(),
        *extra_args,
    ]
    return run(cmd, check=False, timeout=timeout)


def validate_png(path: Path, label: str) -> None:
    if not path.exists():
        raise DeliveryError(f"Capture missing: {label} ({path})")
    size = path.stat().st_size
    if size < MIN_PNG_BYTES:
        raise DeliveryError(f"Capture too small ({size} bytes): {label} ({path})")


def wait_for_png(path: Path, *, attempts: int = 12, delay_s: float = 0.5) -> None:
    for _ in range(attempts):
        if path.exists() and path.stat().st_size >= MIN_PNG_BYTES:
            return
        time.sleep(delay_s)
    validate_png(path, path.name)


def smoke_test() -> None:
    result = run_godot(["--smoke-test"], timeout=120)
    out = result.stdout + result.stderr
    if result.returncode != 0 or "smoke test: PASS" not in out:
        if "Parse Error" in out or "Failed to load script" in out:
            raise DeliveryError(f"Godot parse/runtime failure:\n{out}")
        raise DeliveryError(f"Smoke test failed (exit {result.returncode}):\n{out}")
    print("Smoke test: PASS")


def live_capture(include_gameplay: bool = True) -> dict[str, Path]:
    LIVE_DIR.mkdir(parents=True, exist_ok=True)
    args = ["--live-capture"]
    if include_gameplay:
        args.append("gameplay")
    result = run_godot(args, timeout=600)
    out = result.stdout + result.stderr
    if result.returncode != 0:
        raise DeliveryError(f"Live capture failed (exit {result.returncode}):\n{out}")
    expected = {
        "landscape": LIVE_DIR / "latest_landscape.png",
        "portrait": LIVE_DIR / "latest_portrait.png",
    }
    if include_gameplay:
        expected["gameplay"] = LIVE_DIR / "latest_gameplay.png"
    for label, path in expected.items():
        wait_for_png(path)
        validate_png(path, label)
    print("Live capture: PASS")
    return expected


M031_DIR = ROOT / "artifacts" / "m03_1"


def m03_1_capture() -> dict[str, Path]:
    M031_DIR.mkdir(parents=True, exist_ok=True)
    result = run_godot(["--m03_1-capture"], timeout=600)
    out = result.stdout + result.stderr
    if result.returncode != 0:
        raise DeliveryError(f"M03.1 capture failed (exit {result.returncode}):\n{out}")
    expected = {
        "landscape_world_final": M031_DIR / "landscape_world_final.png",
        "portrait_world_final": M031_DIR / "portrait_world_final.png",
        "portrait_combat_final": M031_DIR / "portrait_combat_final.png",
    }
    for label, path in expected.items():
        wait_for_png(path)
        validate_png(path, label)
    print("M03.1 visual capture: PASS")
    return expected


def m03_1_multiplayer_e2e() -> None:
    script = ROOT / "tools" / "m03_1_multiplayer_e2e.py"
    result = run([sys.executable, str(script)], cwd=ROOT, timeout=600)
    out = result.stdout + result.stderr
    if result.returncode != 0:
        raise DeliveryError(f"M03.1 multiplayer E2E failed:\n{out}")
    log_path = M031_DIR / "multiplayer_e2e.log"
    if not log_path.exists():
        raise DeliveryError("Missing multiplayer_e2e.log")
    print("M03.1 multiplayer E2E: PASS")


def m04_capture() -> None:
    M04_DIR = ROOT / "artifacts" / "m04"
    M04_DIR.mkdir(parents=True, exist_ok=True)
    result = run_godot(["--m04-capture"], timeout=900)
    out = result.stdout + result.stderr
    if result.returncode != 0:
        raise DeliveryError(f"M04 capture failed (exit {result.returncode}):\n{out}")
    expected = [
        "gameplay_landscape.png",
        "gameplay_portrait.png",
        "inventory_landscape.png",
        "inventory_portrait.png",
        "character_landscape.png",
        "character_portrait.png",
        "equipment_comparison.png",
        "equipment_equipped.png",
        "skillbar_landscape.png",
        "skillbar_portrait.png",
        "level_up.png",
    ]
    for name in expected:
        wait_for_png(M04_DIR / name)
        validate_png(M04_DIR / name, name)
    print("M04 visual capture: PASS")


M04_1_DIR = ROOT / "artifacts" / "m04_1"


def m04_1_capture() -> None:
    M04_1_DIR.mkdir(parents=True, exist_ok=True)
    result = run_godot(["--m04_1-capture"], timeout=900)
    out = result.stdout + result.stderr
    if result.returncode != 0:
        raise DeliveryError(f"M04.1 capture failed (exit {result.returncode}):\n{out}")
    expected = [
        "01_gameplay_landscape.png",
        "02_gameplay_portrait.png",
        "03_inventory_landscape.png",
        "04_inventory_portrait.png",
        "05_character_landscape.png",
        "06_character_portrait.png",
        "07_equipment_landscape.png",
        "08_equipment_portrait.png",
        "09_item_comparison.png",
        "10_skillbar_landscape.png",
        "11_skillbar_portrait.png",
        "12_skill_cooldown.png",
        "13_level_up_landscape.png",
        "14_level_up_portrait.png",
        "15_canopy_fade_landscape.png",
        "16_canopy_fade_portrait.png",
        "17_clean_gameplay_no_debug.png",
    ]
    for name in expected:
        wait_for_png(M04_1_DIR / name)
        validate_png(M04_1_DIR / name, name)
    print("M04.1 visual capture: PASS")


def measure_snapshot_payload() -> int:
    result = run_godot(["--measure-snapshot"], timeout=120)
    out = result.stdout + result.stderr
    if result.returncode != 0:
        raise DeliveryError(f"Snapshot measure failed (exit {result.returncode}):\n{out}")
    match = re.search(r"SNAPSHOT_LITE_BYTES=(\d+)", out)
    if not match:
        raise DeliveryError(f"Snapshot measure missing payload line:\n{out}")
    lite_bytes = int(match.group(1))
    print(f"Snapshot lite payload: {lite_bytes} bytes")
    return lite_bytes


def git(*args: str, check: bool = True) -> str:
    result = run(["git", *args], check=check)
    return (result.stdout or "").strip()


def ensure_git_repo() -> None:
    if not (ROOT / ".git").exists():
        raise DeliveryError("Not a git repository. Run git init and add origin first.")


def check_clean_merge_state() -> None:
    status = git("status", "--porcelain")
    if "UU " in status or "AA " in status:
        raise DeliveryError("Merge conflict detected. Resolve before delivery.")
    has_commit = run(["git", "rev-parse", "HEAD"], cwd=ROOT, check=False)
    if has_commit.returncode != 0:
        return
    branch = git("rev-parse", "--abbrev-ref", "HEAD")
    if branch != "main":
        raise DeliveryError(f"Expected branch main, got {branch}")


def write_live_build(
    *,
    milestone: str,
    commit_sha: str,
    runtime: str,
    captures: dict[str, Path],
    known_issues: list[str],
) -> None:
    LIVE_DIR.mkdir(parents=True, exist_ok=True)
    lines = [
        "BRAMBLE LIVE BUILD",
        "",
        f"Milestone: {milestone}",
        f"Commit: {commit_sha or '(pending)'}",
        f"Date: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}",
        "Godot: 4.7.2",
        f"Main Scene: {read_project_main_scene()}",
        f"Runtime Test: {runtime}",
        f"Landscape Capture: {captures.get('landscape', LIVE_DIR / 'latest_landscape.png')}",
        f"Portrait Capture: {captures.get('portrait', LIVE_DIR / 'latest_portrait.png')}",
        f"Gameplay Capture: {captures.get('gameplay', 'n/a')}",
        "Known Issues:",
    ]
    for issue in known_issues:
        lines.append(f"- {issue}")
    (LIVE_DIR / "LIVE_BUILD.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def commit_only(message: str) -> tuple[str, str]:
    ensure_git_repo()
    check_clean_merge_state()
    try:
        prev_head = git("rev-parse", "HEAD")
    except DeliveryError:
        prev_head = ""

    git("add", "-A")
    staged = git("diff", "--cached", "--name-only")
    if not staged.strip():
        raise DeliveryError("Nothing to commit after staging.")

    run(["git", "commit", "-m", message], cwd=ROOT)
    new_head = git("rev-parse", "HEAD")
    return prev_head, new_head


def push_to_origin() -> str:
    remote = git("remote", "get-url", "origin", check=False)
    if not remote:
        raise DeliveryError("No origin remote configured.")
    fetch = run(["git", "fetch", "origin", "main"], cwd=ROOT, check=False)
    if fetch.returncode != 0 and "couldn't find remote ref" not in (fetch.stderr or "").lower():
        print(f"Fetch note: {fetch.stderr}")

    local_main = git("rev-parse", "main")
    remote_ref = run(["git", "rev-parse", "origin/main"], cwd=ROOT, check=False)
    if remote_ref.returncode == 0:
        behind = run(
            ["git", "rev-list", "--count", f"{local_main}..origin/main"],
            cwd=ROOT,
            check=False,
        )
        ahead = run(
            ["git", "rev-list", "--count", f"origin/main..{local_main}"],
            cwd=ROOT,
            check=False,
        )
        if behind.returncode == 0 and int((behind.stdout or "0").strip() or 0) > 0:
            if ahead.returncode == 0 and int((ahead.stdout or "0").strip() or 0) == 0:
                raise DeliveryError(
                    "Local main is behind origin/main. Pull/merge manually — no force push."
                )

    push_result = run(["git", "push", "-u", "origin", "main"], cwd=ROOT, check=False)
    if push_result.returncode != 0:
        raise DeliveryError(f"Push failed:\n{push_result.stdout}\n{push_result.stderr}")
    return git("rev-parse", "origin/main")


def merge_remote_readme_if_needed() -> None:
    """First-time setup: merge origin/main README without overwriting local work."""
    fetch = run(["git", "fetch", "origin", "main"], cwd=ROOT, check=False)
    if fetch.returncode != 0:
        return
    has_remote = run(["git", "rev-parse", "origin/main"], cwd=ROOT, check=False)
    if has_remote.returncode != 0:
        return
    merge_base = run(["git", "merge-base", "HEAD", "origin/main"], cwd=ROOT, check=False)
    if merge_base.returncode == 0 and merge_base.stdout.strip():
        return
    merge = run(
        ["git", "merge", "origin/main", "--allow-unrelated-histories", "-m", "chore: merge remote README"],
        cwd=ROOT,
        check=False,
    )
    if merge.returncode != 0:
        status = git("status", "--porcelain", check=False)
        if "UU " in status or "AA " in status:
            raise DeliveryError("Merge conflict with origin/main while merging remote README.")
        raise DeliveryError(f"Merge with origin/main failed:\n{merge.stdout}\n{merge.stderr}")


def count_staged_files() -> int:
    out = git("diff", "--cached", "--name-only", check=False)
    if not out:
        out = git("ls-files", check=False)
    return len([l for l in out.splitlines() if l.strip()])


def main() -> int:
    parser = argparse.ArgumentParser(description="BRAMBLE delivery workflow")
    parser.add_argument("--milestone", default="m02.2", help="Milestone tag for LIVE_BUILD.md")
    parser.add_argument("--message", default="", help="Git commit message")
    parser.add_argument("--capture-only", action="store_true")
    parser.add_argument("--no-push", action="store_true")
    parser.add_argument("--skip-gameplay", action="store_true")
    parser.add_argument(
        "--known-issues",
        default="Full MMO combat replication deferred to Authority milestone",
        help="Comma-separated known issues",
    )
    args = parser.parse_args()

    report = {
        "implementation": "PASS",
        "runtime": "FAIL",
        "capture": "FAIL",
        "commit": "FAIL",
        "push": "FAIL",
    }

    try:
        smoke_test()
        report["runtime"] = "PASS"

        captures = live_capture(include_gameplay=not args.skip_gameplay)
        report["capture"] = "PASS"
        if args.milestone.startswith("m03.1"):
            m03_1_capture()
            m03_1_multiplayer_e2e()
        if args.milestone.startswith("m04.1"):
            m04_1_capture()
            measure_snapshot_payload()
            m03_1_multiplayer_e2e()
        elif args.milestone.startswith("m04"):
            m04_capture()

        if args.capture_only:
            write_live_build(
                milestone=args.milestone,
                commit_sha="",
                runtime=report["runtime"],
                captures=captures,
                known_issues=[x.strip() for x in args.known_issues.split(",") if x.strip()],
            )
            print(json.dumps(report, indent=2))
            return 0

        message = args.message or f"feat({args.milestone}): canonical BRAMBLE_GAME delivery"
        issues = [x.strip() for x in args.known_issues.split(",") if x.strip()]

        # Stage everything except what gitignore excludes; write LIVE_BUILD after capture
        write_live_build(
            milestone=args.milestone,
            commit_sha="",
            runtime=report["runtime"],
            captures=captures,
            known_issues=issues,
        )

        prev, new = commit_only(message)
        report["commit"] = "PASS"
        merge_remote_readme_if_needed()

        write_live_build(
            milestone=args.milestone,
            commit_sha=new,
            runtime=report["runtime"],
            captures=captures,
            known_issues=issues,
        )
        run(["git", "add", str(LIVE_DIR / "LIVE_BUILD.md")], cwd=ROOT)
        run(
            ["git", "commit", "-m", f"docs(live): update LIVE_BUILD for {new[:8]}"],
            cwd=ROOT,
        )
        new = git("rev-parse", "HEAD")

        remote = ""
        if not args.no_push:
            remote = push_to_origin()
            report["push"] = "PASS"
        else:
            report["push"] = "SKIP"
            remote = git("rev-parse", "origin/main", check=False) or ""

        print("\n=== BRAMBLE DELIVERY REPORT ===")
        print(f"Repository: https://github.com/Broosskyy/Bramble.git")
        print("Branch: main")
        print("Remote: origin")
        print(f"Previous HEAD: {prev or '(none)'}")
        print(f"New HEAD: {new}")
        print(f"Remote HEAD: {remote}")
        print(f"Files committed: {count_staged_files()}")
        print(f"Runtime: {report['runtime']}")
        print(f"Landscape capture: {captures['landscape']}")
        print(f"Portrait capture: {captures['portrait']}")
        print(f"Gameplay capture: {captures.get('gameplay', 'n/a')}")
        print(f"Commit SHA: {new}")
        print(f"Push: {report['push']}")
        print(f"local == remote: {new == remote}")
        print(f"Remaining issues: {', '.join(issues)}")
        if new == remote and report["push"] == "PASS":
            print("GITHUB_DELIVERY_WORKFLOW = ACTIVE")
        print(json.dumps(report, indent=2))
        return 0

    except DeliveryError as exc:
        print(f"DELIVERY BLOCKED: {exc}", file=sys.stderr)
        print(json.dumps(report, indent=2))
        return 1


if __name__ == "__main__":
    sys.exit(main())
