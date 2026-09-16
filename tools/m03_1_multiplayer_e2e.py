#!/usr/bin/env python3
"""Two-process Godot ENet multiplayer E2E for M03.1."""

from __future__ import annotations

import os
import random
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GODOT = Path(
    os.environ.get(
        "BRAMBLE_GODOT",
        r"C:\Users\manue\Downloads\Godot-4.7.2\editor\Godot_v4.7.2-stable_win64.exe",
    )
)
ARTIFACTS = ROOT / "artifacts" / "m03_1"
LOG = ARTIFACTS / "multiplayer_e2e.log"
PORT = 27900 + (os.getpid() % 80) + random.randint(0, 9)
MIN_PNG = 20_000


def read_main_scene() -> str:
    text = (ROOT / "project.godot").read_text(encoding="utf-8")
    match = re.search(r'run/main_scene="([^"]+)"', text)
    return match.group(1) if match else "res://scenes/main.tscn"


def godot_cmd(*user_args: str) -> list[str]:
    return [str(GODOT), "--path", str(ROOT), read_main_scene(), *user_args]


def wait_png(path: Path, timeout_s: float = 90.0) -> None:
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        if path.exists() and path.stat().st_size >= MIN_PNG:
            return
        time.sleep(0.5)
    raise RuntimeError(f"Missing capture: {path}")


def wait_log(pattern: str, timeout_s: float = 120.0) -> None:
    deadline = time.time() + timeout_s
    rx = re.compile(pattern)
    while time.time() < deadline:
        if LOG.exists() and rx.search(LOG.read_text(encoding="utf-8", errors="replace")):
            return
        time.sleep(0.5)
    raise RuntimeError(f"Log pattern not found: {pattern}")


def run_client(label: str) -> subprocess.CompletedProcess:
    print(f"Starting client ({label})...")
    log_path = ARTIFACTS / f"client_{label.replace('-', '_')}.log"
    with open(log_path, "w", encoding="utf-8") as log_file:
        return subprocess.run(
            godot_cmd(
                "--join",
                "127.0.0.1",
                f"--port={PORT}",
                "--no-lobby",
                "--m03_1-e2e=client",
            ),
            cwd=str(ROOT),
            stdout=log_file,
            stderr=subprocess.STDOUT,
            timeout=420,
        )


def main() -> int:
    if not GODOT.exists():
        print(f"Godot not found: {GODOT}", file=sys.stderr)
        return 1

    ARTIFACTS.mkdir(parents=True, exist_ok=True)
    if LOG.exists():
        LOG.unlink()
    print(f"E2E port: {PORT}")
    time.sleep(2.0)

    host_log = ARTIFACTS / "host_process.log"
    host = subprocess.Popen(
        godot_cmd("--host", f"--port={PORT}", "--no-lobby", "--m03_1-e2e=host"),
        cwd=str(ROOT),
        stdout=open(host_log, "w", encoding="utf-8"),
        stderr=subprocess.STDOUT,
    )
    try:
        time.sleep(4.0)
        client1 = run_client("session-1")
        if client1.returncode != 0:
            raise RuntimeError(f"Client session 1 failed ({client1.returncode})")

        wait_png(ARTIFACTS / "client_with_host.png")
        wait_log(r"waiting_reconnect", timeout_s=240.0)

        client2 = run_client("reconnect")
        if client2.returncode != 0:
            raise RuntimeError(f"Client reconnect failed ({client2.returncode})")

        wait_log(r"HOST_E2E_PASS", timeout_s=480.0)
        host.wait(timeout=90)
        if host.returncode != 0:
            raise RuntimeError(f"Host failed ({host.returncode})")

        wait_png(ARTIFACTS / "host_with_client.png")
        log_text = LOG.read_text(encoding="utf-8", errors="replace")
        required = [
            "host_start",
            "client_connected",
            "remote_player_created",
            "host_movement_complete",
            "client_movement_complete",
            "screenshot host_with_client.png",
            "screenshot client_with_host.png",
            "disconnect_cleanup",
            "reconnect_ok",
            "combat_sanity",
        ]
        missing = [item for item in required if item not in log_text]
        if missing:
            raise RuntimeError(f"Log missing entries: {missing}")

        print("M03.1 multiplayer E2E: PASS")
        return 0
    finally:
        if host.poll() is None:
            host.kill()
            host.wait(timeout=10)


if __name__ == "__main__":
    sys.exit(main())
