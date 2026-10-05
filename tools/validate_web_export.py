#!/usr/bin/env python3
"""Validate the deterministic Bramble Godot web-export artifact."""

from __future__ import annotations

import argparse
import gzip
import json
import re
import sys
from pathlib import Path


REQUIRED_FILES = (
    "index.html",
    "index.js",
    "index.wasm",
    "index.pck",
    "index.service.worker.js",
)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--build-dir", default="build/web")
    parser.add_argument("--max-transfer-mib", type=float, default=48.0)
    args = parser.parse_args()

    root = Path(args.build_dir)
    failures: list[str] = []
    for name in REQUIRED_FILES:
        path = root / name
        if not path.is_file():
            failures.append(f"missing: {path}")
        elif path.stat().st_size == 0:
            failures.append(f"empty: {path}")

    if failures:
        print("WEB_EXPORT_GATE=FAIL")
        print("\n".join(failures))
        return 1

    html = (root / "index.html").read_text(encoding="utf-8")
    match = re.search(r"const GODOT_CONFIG = (\{.*?\});", html)
    if not match:
        failures.append("index.html has no GODOT_CONFIG")
    else:
        config = json.loads(match.group(1))
        declared = config.get("fileSizes", {})
        for name in ("index.pck", "index.wasm"):
            actual = (root / name).stat().st_size
            if declared.get(name) != actual:
                failures.append(
                    f"size mismatch for {name}: html={declared.get(name)} actual={actual}"
                )

    files = [path for path in root.iterdir() if path.is_file() and not path.name.endswith(".import")]
    raw_bytes = sum(path.stat().st_size for path in files)
    transfer_bytes = sum(len(gzip.compress(path.read_bytes(), compresslevel=9)) for path in files)
    transfer_mib = transfer_bytes / 1024 / 1024
    if transfer_mib > args.max_transfer_mib:
        failures.append(
            f"estimated gzip transfer {transfer_mib:.2f} MiB exceeds {args.max_transfer_mib:.2f} MiB"
        )

    result = {
        "status": "FAIL" if failures else "PASS",
        "raw_mib": round(raw_bytes / 1024 / 1024, 2),
        "estimated_gzip_mib": round(transfer_mib, 2),
        "pck_mib": round((root / "index.pck").stat().st_size / 1024 / 1024, 2),
        "wasm_mib": round((root / "index.wasm").stat().st_size / 1024 / 1024, 2),
        "budget_mib": args.max_transfer_mib,
        "failures": failures,
    }
    print(json.dumps(result, indent=2))
    print(f"WEB_EXPORT_GATE={result['status']}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
