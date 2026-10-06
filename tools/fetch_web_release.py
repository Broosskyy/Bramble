#!/usr/bin/env python3
"""Deploy only the validated Web export for Vercel's exact source commit."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import tempfile
import time
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPOSITORY = "Broosskyy/Bramble"


def download(url: str, destination: Path) -> None:
    request = urllib.request.Request(url, headers={"User-Agent": "Bramble-Web-Deployment"})
    with urllib.request.urlopen(request, timeout=60) as response, destination.open("wb") as out:
        shutil.copyfileobj(response, out)


def install(bundle: Path, manifest: dict, revision: str, output: Path) -> None:
    if manifest.get("status") != "PASS" or manifest.get("target") != "web":
        raise RuntimeError("Release is not a validated Web build")
    if manifest.get("source_commit") != revision or manifest.get("source_modified") is not False:
        raise RuntimeError("Release source does not match this deployment")
    artifacts = manifest.get("artifacts", [])
    metadata = next((a for a in artifacts if a.get("path") == "build/bramble-web.zip"), None)
    if not metadata or bundle.stat().st_size != metadata["bytes"]:
        raise RuntimeError("Web bundle size mismatch")
    with bundle.open("rb") as stream:
        digest = hashlib.sha256()
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    if digest.hexdigest() != metadata["sha256"]:
        raise RuntimeError("Web bundle checksum mismatch")
    with zipfile.ZipFile(bundle) as archive:
        names = archive.namelist()
        if any(Path(n).name != n or "\\" in n for n in names):
            raise RuntimeError("Web bundle must contain only flat export files")
        if not {"index.html", "index.js", "index.wasm", "index.pck"}.issubset(names):
            raise RuntimeError("Web bundle is missing required runtime files")
        if archive.testzip() is not None:
            raise RuntimeError("Corrupt Web bundle")
        output.mkdir(parents=True, exist_ok=True)
        for file in output.iterdir():
            if file.is_file():
                file.unlink()
        archive.extractall(output)
    (output / "build-info.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--commit", default=os.environ.get("VERCEL_GIT_COMMIT_SHA"))
    parser.add_argument("--timeout", type=int, default=1200)
    args = parser.parse_args()
    if not args.commit or not re.fullmatch(r"[0-9a-f]{40}", args.commit):
        raise RuntimeError("An exact 40-character source commit is required")
    base = f"https://github.com/{REPOSITORY}/releases/download/web-{args.commit}"
    deadline = time.monotonic() + args.timeout
    with tempfile.TemporaryDirectory(prefix="bramble-web-") as directory:
        temp = Path(directory)
        while True:
            try:
                download(base + "/build-manifest.json", temp / "manifest.json")
                download(base + "/bramble-web.zip", temp / "web.zip")
                break
            except (urllib.error.URLError, TimeoutError) as error:
                if isinstance(error, urllib.error.HTTPError) and error.code not in (404, 429, 500, 502, 503, 504):
                    raise
                if time.monotonic() >= deadline:
                    raise RuntimeError("Timed out waiting for the matching GitHub Web build; inspect Actions") from error
                print(f"Waiting for validated Web release {args.commit[:7]}...", flush=True)
                time.sleep(15)
        install(temp / "web.zip", json.loads((temp / "manifest.json").read_text()), args.commit, ROOT / "build/web")
    print(f"Web deployment ready: source {args.commit}", flush=True)


if __name__ == "__main__":
    main()
