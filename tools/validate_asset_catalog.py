#!/usr/bin/env python3
"""Validate reviewed asset identities without trusting source names."""

from __future__ import annotations

import csv
from collections import defaultdict
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "assets" / "game"
CATALOG = GAME / "_catalog"
OVERRIDES = CATALOG / "SEMANTIC_OVERRIDES.json"
MANIFEST = CATALOG / "ASSET_MANIFEST.csv"
MAPPING = CATALOG / "SOURCE_MAPPING.csv"


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []
    advisories: list[str] = []
    payload = json.loads(OVERRIDES.read_text(encoding="utf-8"))
    overrides: dict[str, dict] = payload["overrides"]

    with MANIFEST.open(newline="", encoding="utf-8") as handle:
        manifest = list(csv.DictReader(handle))
    with MAPPING.open(newline="", encoding="utf-8") as handle:
        mapping = list(csv.DictReader(handle))

    for source_path, override in overrides.items():
        canonical = override["canonical_path"]
        asset_type = override["asset_type"]
        rows = [row for row in manifest if row["source_path"] == source_path]
        if len(rows) != 1:
            fail(errors, f"manifest source row count {len(rows)}: {source_path}")
        elif rows[0]["canonical_path"].replace("\\", "/") != canonical:
            fail(errors, f"manifest canonical mismatch: {source_path}")
        elif rows[0]["asset_type"] != asset_type:
            fail(errors, f"manifest type mismatch: {source_path}")

        mapped = [
            row for row in mapping
            if row["source_path"] == source_path
            and row["canonical_path"].replace("\\", "/") == canonical
        ]
        if len(mapped) != 1:
            fail(errors, f"source mapping mismatch: {source_path}")
        if not (GAME / canonical).is_file():
            fail(errors, f"missing canonical asset: {canonical}")

    required_moorling = [
        *(f"monsters/moorling/directions/kit60_{direction}.png"
          for direction in ("front", "right", "back", "left")),
        *(f"monsters/moorling/actions/{action}.png"
          for action in ("idle", "attack", "hit", "defeated")),
        *(f"monsters/moorling/animations/{state}_{ordinal:02d}/{index:02d}_{state}_{ordinal:02d}.png"
          for state, start in (("idle", 0), ("attack", 4), ("hit", 0), ("defeated", 4))
          for ordinal, index in enumerate(range(start, start + 4), 1)),
    ]
    for relative in required_moorling:
        if not (GAME / relative).is_file():
            fail(errors, f"missing Moorling runtime asset: {relative}")

    forbidden = [
        "monsters/moorling/kit21_master.png",
        "monsters/moorling/kit60_master.png",
        "monsters/moorling/kit70_master.png",
        "monsters/moorling/kit71_master.png",
        *(f"monsters/moorling/directions/kit21_{direction}.png"
          for direction in ("front", "right", "back", "left")),
        "references/masters/ui/kit_25_hud_frames_master.png",
        "references/masters/ui/kit_26_menu_frames_master.png",
        "references/masters/ui/kit_27_touch_controls_master.png",
        "references/masters/ui/kit_28_raid_loot_ui_master.png",
        "references/masters/ui/kit_29_world_system_ui_master.png",
        "references/concepts/inventory_portrait_concept.png",
        "references/previews/mooring_action_poses_master.png",
    ]
    manifest_paths = {row["canonical_path"].replace("\\", "/") for row in manifest}
    for relative in forbidden:
        if (GAME / relative).exists():
            fail(errors, f"mislabeled duplicate still exists: {relative}")
        if relative in manifest_paths:
            fail(errors, f"mislabeled canonical path remains in manifest: {relative}")

    runtime_source_ref = re.compile(r"assets/game/references/(?:source_sheets|masters)/")
    for folder, suffixes in (("scripts", ("*.gd",)), ("scenes", ("*.tscn",))):
        for pattern in suffixes:
            for path in (ROOT / folder).rglob(pattern):
                if runtime_source_ref.search(path.read_text(encoding="utf-8")):
                    fail(errors, f"runtime references a source sheet: {path.relative_to(ROOT)}")

    for import_path in [
        *(GAME / "world" / "vegetation").glob("*.png.import"),
        *(GAME / "references" / "source_sheets").glob("kit_6*_moorling*.png.import"),
        *(GAME / "references" / "source_sheets").glob("kit_7*_moorling*.png.import"),
    ]:
        text = import_path.read_text(encoding="utf-8")
        expected = f'res://{import_path.relative_to(ROOT).as_posix()[:-7]}'
        match = re.search(r'^source_file="([^"]+)"$', text, re.MULTILINE)
        if not match or match.group(1) != expected:
            fail(errors, f"stale import source_file: {import_path.relative_to(ROOT)}")

    by_canonical: dict[str, list[dict]] = defaultdict(list)
    for row in manifest:
        canonical = row["canonical_path"].replace("\\", "/")
        if canonical:
            by_canonical[canonical].append(row)
    for canonical, rows in sorted(by_canonical.items()):
        hashes = {row["sha256"] for row in rows}
        if len(hashes) > 1:
            sources = ", ".join(row["source_path"] for row in rows)
            warnings.append(f"conflicting canonical path {canonical}: {sources}")

    historical_masters = [
        path for path in GAME.rglob("*master*.png")
        if "references" not in path.relative_to(GAME).parts
    ]
    if historical_masters:
        advisories.append(
            f"{len(historical_masters)} historical master sheets remain outside references"
        )
    if (GAME / "npcs" / "merchant").is_dir() and (GAME / "npcs" / "merchants").is_dir():
        advisories.append("merchant/merchants entity split remains REVIEW_REQUIRED")

    if errors:
        print("ASSET CATALOG INTEGRITY: FAIL")
        for error in errors:
            print(f"- {error}")
        return 1
    if warnings:
        print(f"REVIEW_REQUIRED: {len(warnings)} pre-existing canonical collisions")
        for warning in warnings:
            print(f"- {warning}")
    for advisory in advisories:
        print(f"REVIEW_REQUIRED: {advisory}")
    print(
        "ASSET CATALOG INTEGRITY: PASS "
        f"({len(overrides)} overrides, {len(required_moorling)} Moorling runtime assets)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
