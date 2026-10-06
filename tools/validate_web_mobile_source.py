#!/usr/bin/env python3
"""Static source gate for Bramble's mobile browser runtime contract."""

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]


def require_text(path: str, needles: tuple[str, ...], failures: list[str]) -> None:
    target = ROOT / path
    if not target.is_file():
        failures.append(f"missing: {path}")
        return
    text = target.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            failures.append(f"{path}: missing {needle!r}")


def main() -> int:
    failures: list[str] = []
    require_text(
        "project.godot",
        (
            'window/stretch/mode="canvas_items"',
            "window/handheld/orientation=6",
        ),
        failures,
    )
    require_text(
        "export_presets.cfg",
        (
            'name="Web Mobile Gate"',
            "variant/thread_support=false",
            "progressive_web_app/enabled=true",
            "html/canvas_resize_policy=2",
        ),
        failures,
    )
    require_text(
        "scripts/web_platform_service.gd",
        (
            "DisplayServer.get_display_safe_area()",
            "DisplayServer.WINDOW_MODE_FULLSCREEN",
            "viewport_metrics_changed",
            "calculate_logical_safe_insets",
        ),
        failures,
    )
    require_text(
        "scripts/production_hud.gd",
        (
            'fullscreen_btn.name = "FullscreenToggle"',
            "_safe_insets",
            "_web_platform_service.toggle_fullscreen()",
        ),
        failures,
    )
    require_text(
        "scenes/main.tscn",
        (
            'path="res://scripts/web_platform_service.gd"',
            '[node name="WebPlatformService"',
        ),
        failures,
    )

    zero_byte_assets = [
        str(path.relative_to(ROOT))
        for path in (ROOT / "assets").rglob("*")
        if path.is_file() and path.stat().st_size == 0
    ]
    failures.extend(f"zero-byte asset: {path}" for path in zero_byte_assets)

    status = "FAIL" if failures else "PASS"
    print(f"WEB_MOBILE_SOURCE_GATE={status}")
    for failure in failures:
        print(f"- {failure}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())

