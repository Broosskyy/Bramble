#!/usr/bin/env python3
"""
ASSET FOUNDATION 01 — BRAMBLE → assets/game canonical library builder.
Extracts _asset_import ZIPs to _asset_work, classifies, copies to assets/game,
and generates _catalog documentation. Does NOT modify _asset_import.
"""

from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import shutil
import zipfile
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from typing import Optional

PROJECT_ROOT = Path(__file__).resolve().parents[1]
ASSET_IMPORT = PROJECT_ROOT / "_asset_import"
ASSET_WORK = PROJECT_ROOT / "_asset_work"
ASSET_GAME = PROJECT_ROOT / "assets" / "game"
CATALOG = ASSET_GAME / "_catalog"
SEMANTIC_OVERRIDES = CATALOG / "SEMANTIC_OVERRIDES.json"

SKIP_EXTRACT_NAMES = {".ds_store", "thumbs.db", "desktop.ini"}
SKIP_COPY_EXTENSIONS = {".py"}  # tooling inside kits, not game assets

DIRECTIONS = [
    "front", "back", "left", "right",
    "front_left", "front_right", "back_left", "back_right",
]
ANIM_STATES = [
    "idle", "walk", "run", "attack", "cast", "hit", "defeated", "death",
]

KIT_FOLDER_RE = re.compile(r"^(\d{1,2})_([a-z0-9_]+)$", re.I)
KIT_FILE_RE = re.compile(r"^(\d{1,2})_([a-z0-9_]+)\.(png|jpg|webp)$", re.I)
FRAME_RE = re.compile(r"^(\d{2})_([a-z0-9_]+)(?:_(\d{2}))?\.(png|webp)$", re.I)


@dataclass
class FileRecord:
    source_zip: str
    source_path: str  # path inside zip
    work_path: Path
    source_kit: Optional[int]
    kit_folder: str
    filename: str
    ext: str
    sha256: str
    size: int
    classification: str = "UNKNOWN"
    category: str = ""
    subcategory: str = ""
    asset_type: str = ""
    entity_name: str = ""
    direction: str = ""
    animation_state: str = ""
    frame: str = ""
    canonical_path: str = ""
    status: str = "pending"
    notes: str = ""
    copy_to_production: bool = False
    semantic_alias: bool = False


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def safe_extract_zip(zip_path: Path, dest_root: Path) -> list[str]:
    """Extract zip with path-traversal protection."""
    dest_root.mkdir(parents=True, exist_ok=True)
    extracted: list[str] = []
    with zipfile.ZipFile(zip_path) as zf:
        for info in zf.infolist():
            name = info.filename.replace("\\", "/")
            if info.is_dir():
                continue
            base = os.path.basename(name)
            if base.lower() in SKIP_EXTRACT_NAMES or base.startswith("._"):
                continue
            target = (dest_root / name).resolve()
            if not str(target).startswith(str(dest_root.resolve())):
                raise RuntimeError(f"Path traversal blocked: {name} in {zip_path.name}")
            target.parent.mkdir(parents=True, exist_ok=True)
            with zf.open(info) as src, open(target, "wb") as dst:
                shutil.copyfileobj(src, dst)
            extracted.append(name)
    return extracted


def parse_kit_folder(folder_name: str) -> tuple[Optional[int], str]:
    m = KIT_FOLDER_RE.match(folder_name)
    if m:
        return int(m.group(1)), m.group(2)
    return None, folder_name


def detect_source_kit(source_path: str, parts: tuple[str, ...]) -> tuple[Optional[int], str]:
    """Detect kit number from folder or root-level numbered filenames (kits 1–10)."""
    kit_folder = ""
    for i, p in enumerate(parts):
        m = KIT_FOLDER_RE.match(p)
        if m:
            kit_folder = "/".join(parts[: i + 1])
            return int(m.group(1)), kit_folder
    # Kits 1–10: numbered sheets at archive root (e.g. 01_terrain_meadow_earth.png)
    for p in parts:
        m = KIT_FILE_RE.match(p)
        if m:
            return int(m.group(1)), f"kit_{int(m.group(1)):02d}_{m.group(2)}"
    # BRAMBLE_10_Asset_Kits subfolder heuristics
    sp = source_path.replace("\\", "/").lower()
    if "bramble_10_asset_kits" in sp:
        subkit_map = {
            "/animation/npc_": 8,
            "/characters/": 7,
            "/equipment/": 7,
            "/specialists/": 10,
            "/vfx/": 9,
        }
        for key, kit in subkit_map.items():
            if key in sp:
                return kit, f"kit_{kit:02d}_bundle"
    return None, kit_folder


def detect_entity_from_folder(kit_suffix: str) -> str:
    s = kit_suffix.lower()
    # strip common suffixes
    for suf in (
        "_directions_actions", "_directions", "_male_female",
        "_8_directions", "_locomotion_damage", "_idle_walk",
        "_run_damage", "_idle_attack", "_hit_defeated",
        "_idle_greet", "_idle_talk", "_pose_layers",
        "_specialist_male_female", "_monster",
    ):
        if s.endswith(suf):
            s = s[: -len(suf)]
            break
    # strip prefixes
    for pre in ("base_", "village_", "nightfall_", "layered_", "autumn_"):
        if s.startswith(pre):
            s = s[len(pre):]
    # normalize numbered variant suffixes (e.g. blacksmith_8 -> blacksmith)
    s = re.sub(r"_\d+$", "", s)
    return s.replace("-", "_")


MONSTER_ENTITIES = {
    "moorling", "ruins_wisp", "copper_mole", "crystal_beetle", "rootling",
    "lantern_moth", "moss_guardian", "root_guardian",
}

NPC_ENTITIES = {
    "blacksmith", "merchant", "guard", "herbalist", "musician", "quest_giver",
    "village_merchants", "village_npcs",
}

SPECIALIST_ENTITIES = {
    "ember_knight", "pumpkin_reaper", "starter_bow", "starter_mage", "starter_sword",
}


def classify_file(rec: FileRecord) -> None:
    fn = rec.filename.lower()
    rel_parts = PurePosixPath(rec.source_path).parts
    kit_suffix = rec.kit_folder.split("/")[-1] if rec.kit_folder else ""
    _, kit_name = parse_kit_folder(kit_suffix.split("/")[-1] if "/" in kit_suffix else kit_suffix)

    # --- documentation / metadata ---
    if rec.ext in {".md", ".txt", ".html", ".css", ".js"}:
        rec.classification = "DOCUMENTATION"
        rec.copy_to_production = False
        return
    if fn in {"manifest.json", "kit.json", "animation.json", "map_blueprint.json",
              "map_blueprints.json", "style_lock.json", "alpha_test_report.json",
              "qa_report.json", "evolution.json"} or rec.ext == ".csv":
        rec.classification = "DOCUMENTATION"
        rec.copy_to_production = rec.ext == ".json"  # keep json refs in references
        return

    # --- previews / references ---
    if fn in {"preview.webp", "preview.jpg"} or fn == "preview.jpg" or fn.endswith("_concept.png"):
        rec.classification = "PREVIEW"
        rec.copy_to_production = True
        rec.category = "references"
        return
    if fn in {"preview.jpg", "gameplay_landscape_concept.png", "gameplay_portrait_concept.png",
              "inventory_portrait_concept.png", "mooring_action_poses_master.png"}:
        rec.classification = "PREVIEW"
        rec.copy_to_production = True
        rec.category = "references"
        return
    if "camera_concepts" in rec.source_path or "map_concepts" in rec.source_path:
        rec.classification = "REFERENCE"
        rec.copy_to_production = True
        rec.category = "references"
        return
    if fn == "map_preview.jpg":
        rec.classification = "PREVIEW"
        rec.copy_to_production = True
        rec.category = "references"
        return

    # --- masters ---
    if fn in {"master.png", "source_master.png"} or fn.endswith("_master.png"):
        rec.classification = "MASTER"
        rec.copy_to_production = True
        return
    if fn.startswith("painted_material_master"):
        rec.classification = "MASTER"
        rec.copy_to_production = True
        return

    # --- source sheets (kits 1-10 top-level numbered sheets) ---
    if re.match(r"^\d{2}_[a-z_]+\.png$", fn) and "BRAMBLE_10_Asset_Kits" in rec.source_path:
        rec.classification = "SOURCE_SHEET"
        rec.copy_to_production = True
        rec.category = "references"
        rec.subcategory = "source_sheets"
        return
    if fn == "sheet.png":
        rec.classification = "SOURCE_SHEET"
        rec.copy_to_production = True
        rec.category = "references"
        rec.subcategory = "source_sheets"
        return
    if fn.startswith("atlas_") and rec.ext == ".png":
        rec.classification = "SOURCE_SHEET"
        rec.copy_to_production = True
        rec.category = "references"
        rec.subcategory = "source_sheets"
        return
    if "/source_sheets/" in rec.source_path.replace("\\", "/").lower() and "_source_sheet" in fn:
        rec.classification = "SOURCE_SHEET"
        rec.copy_to_production = True
        rec.category = "references"
        rec.subcategory = "source_sheets"
        return

    # --- animation frames ---
    if "/frames/" in rec.source_path.replace("\\", "/").lower():
        rec.classification = "PRODUCTION_FRAME"
        rec.copy_to_production = True
        m = FRAME_RE.match(rec.filename)
        if m:
            rec.frame = m.group(1)
            rec.animation_state = re.sub(r"_\d{2}$", "", m.group(2))
        return

    # --- directions ---
    stem = Path(fn).stem
    if stem in DIRECTIONS:
        rec.classification = "PRODUCTION_DIRECTION"
        rec.direction = stem
        rec.copy_to_production = True
        return

    # --- named animation states as files ---
    state_aliases = {
        "idle_a": "idle", "idle_b": "idle", "idle_ready": "idle",
        "walk_a": "walk", "walk_b": "walk",
        "run_a": "run", "run_b": "run",
        "defeated": "defeated", "death": "death",
        "attack": "attack", "hit": "hit", "cast": "cast",
    }
    if stem in state_aliases:
        rec.classification = "PRODUCTION_FRAME" if stem.endswith(("_a", "_b")) else "PRODUCTION_SINGLE"
        rec.animation_state = state_aliases[stem]
        rec.copy_to_production = True
        if stem.endswith(("_a", "_b")):
            rec.frame = stem[-1]
        return

    # merchant/blacksmith directional npc files
    if re.match(r"^(merchant|blacksmith|ember_knight)_(male|female)_(front|back|left|right)$", stem):
        rec.classification = "PRODUCTION_DIRECTION"
        rec.direction = stem.split("_")[-1]
        rec.copy_to_production = True
        return

    # equipment layers in characters/equipment from kit 1
    if "/equipment/" in rec.source_path.replace("\\", "/").lower():
        rec.classification = "PRODUCTION_LAYER" if "parts" in fn or "separate" in fn else "PRODUCTION_SINGLE"
        rec.copy_to_production = True
        return

    if "/specialists/" in rec.source_path.replace("\\", "/").lower():
        rec.classification = "PRODUCTION_LAYER"
        rec.copy_to_production = True
        rec.entity_name = "specialist_skins"
        return

    if "/animation/" in rec.source_path.replace("\\", "/").lower() and rec.ext == ".png":
        rec.classification = "SOURCE_SHEET"  # animation preview sheets in kit 1
        rec.copy_to_production = True
        rec.category = "references"
        rec.subcategory = "source_sheets"
        return

    if "/characters/" in rec.source_path.replace("\\", "/").lower():
        rec.classification = "SOURCE_SHEET"
        rec.copy_to_production = True
        return

    if rec.ext == ".png" and "preview/" in rec.source_path.lower():
        rec.classification = "PREVIEW"
        rec.copy_to_production = True
        rec.category = "references"
        return

    # default image assets in kit folders
    if rec.ext in {".png", ".webp", ".jpg"}:
        rec.classification = "PRODUCTION_SINGLE"
        rec.copy_to_production = True
        return

    rec.classification = "UNKNOWN"
    rec.copy_to_production = False
    rec.notes = "unclassified extension or path"


def map_canonical_path(rec: FileRecord) -> str:
    """Return canonical path relative to assets/game/."""
    kit_suffix = ""
    if rec.kit_folder:
        kit_suffix = rec.kit_folder.split("/")[-1]
    kit_num, kit_name = parse_kit_folder(kit_suffix) if kit_suffix else (rec.source_kit, "")
    entity = detect_entity_from_folder(kit_name) if kit_name else ""
    fn = rec.filename
    sp = rec.source_path.replace("\\", "/").lower()

    if "/specialists/skins_" in sp:
        gender = "female" if "female" in fn else "male"
        return f"characters/specialists/skins/{gender}.png"

    # references / docs
    if rec.classification in {"PREVIEW", "REFERENCE"}:
        sub = "concepts" if "concept" in fn.lower() else "previews"
        if "camera" in sp:
            sub = "camera"
        if "map" in sp and "concept" in sp:
            sub = "map_concepts"
        return f"references/{sub}/{kit_num or 'misc'}_{fn}" if kit_num else f"references/{sub}/{fn}"

    if rec.classification == "SOURCE_SHEET":
        if rec.category == "references":
            kit_part = f"kit_{kit_num:02d}" if kit_num else "kit_unknown"
            if fn == "sheet.png":
                return f"references/source_sheets/{kit_part}_{kit_name}.png"
            # Root-level numbered sheets (kits 1–10)
            m = KIT_FILE_RE.match(fn)
            if m:
                return f"references/source_sheets/kit_{int(m.group(1)):02d}_{m.group(2)}.png"
            if "/animation/" in sp:
                return f"references/source_sheets/kit_01_animation/{fn}"
            if "/characters/" in sp:
                g = "female" if "female" in fn else "male"
                return f"references/source_sheets/kit_01_base_{g}_unarmed.png"
            return f"references/source_sheets/{kit_part}_{fn}"
        return f"references/source_sheets/{fn}"

    if rec.classification in {"DOCUMENTATION"} and rec.ext == ".json":
        kit_part = f"kit_{kit_num:02d}" if kit_num else "misc"
        return f"references/kit_metadata/{kit_part}/{fn}"

    if rec.classification == "MASTER":
        return _map_master_path(rec, kit_num, kit_name, entity, fn)

    # Kit-category routing by kit name keywords
    kn = kit_name.lower()

    # --- CHARACTERS ---
    if any(x in kn for x in ("base_male", "base_female")) or fn.startswith("base_"):
        gender = "male" if "female" not in kn and "female" not in fn else "female"
        if "8_directions" in kn or rec.classification == "PRODUCTION_DIRECTION":
            if rec.direction:
                return f"characters/base/{gender}/directions/{rec.direction}.png"
            return f"characters/base/{gender}/directions/{Path(fn).stem}.png"
        if "locomotion" in kn or rec.animation_state:
            state = rec.animation_state or Path(fn).stem
            if rec.frame:
                return f"characters/base/{gender}/animations/{state}/{fn}"
            return f"characters/base/{gender}/animations/{state}.png" if "." not in state else f"characters/base/{gender}/animations/{Path(fn).stem}.png"
        if "/characters/" in sp:
            g = "female" if "female" in fn else "male"
            return f"references/source_sheets/kit_01_base_{g}_unarmed.png"
        return f"characters/base/{gender}/{fn}"

    if "armor" in kn and "pose_layers" in kn:
        armor = kn.replace("_pose_layers", "").replace("_armor", "")
        if "/frames/" in sp:
            return f"characters/equipment/armor/{armor}/frames/{fn}"
        return f"characters/equipment/armor/{armor}/{fn}"

    if "unarmed_melee_attack" in kn:
        if "/frames/" in sp:
            gender = "male" if "male" in fn else "female" if "female" in fn else "shared"
            return f"characters/animations/{gender}/attack_melee/{fn}"
        return f"characters/animations/attack_melee/{fn}"
    if "unarmed_ranged_attack" in kn:
        if "/frames/" in sp:
            gender = "male" if "male" in fn else "female" if "female" in fn else "shared"
            return f"characters/animations/{gender}/attack_ranged/{fn}"
        return f"characters/animations/attack_ranged/{fn}"
    if "unarmed_magic_cast" in kn:
        if "/frames/" in sp:
            gender = "male" if "male" in fn else "female" if "female" in fn else "shared"
            return f"characters/animations/{gender}/cast/{fn}"
        return f"characters/animations/cast/{fn}"
    if "ranged_projectiles" in kn or "projectiles_impacts" in kn:
        if "/frames/" in sp:
            return f"combat/projectiles/{fn}"
        return f"combat/projectiles/{fn}"
    if kn == "specialist_wings":
        if "/frames/" in sp:
            return f"characters/specialists/wings/frames/{fn}"
        return f"characters/specialists/wings/{fn}"

    if kn in ("melee_weapons", "ranged_weapons", "magic_weapons_focuses"):
        sub = "weapons" if "weapon" in kn else "weapons"
        if "ranged" in kn:
            sub = "weapons/ranged"
        elif "magic" in kn:
            sub = "weapons/magic"
        else:
            sub = "weapons/melee"
        return f"characters/equipment/{sub}/{fn}"

    if kn == "shields_offhands_tools":
        if "shield" in fn.lower():
            return f"characters/equipment/offhands/{fn}"
        return f"characters/equipment/offhands/{fn}"

    if kn == "armor_outfit_layers":
        return f"characters/equipment/armor/{fn}"
    if "/equipment/" in sp:
        if "weapon" in fn:
            return f"characters/equipment/weapons/{fn}"
        if "armor" in fn:
            return f"characters/equipment/armor/{fn}"
        return f"characters/equipment/{fn}"

    if "specialist" in kn or entity in SPECIALIST_ENTITIES:
        spec = entity or "specialist"
        if rec.direction:
            return f"characters/specialists/{spec}/{rec.direction}.png"
        if "/frames/" in sp:
            return f"characters/specialists/{spec}/frames/{fn}"
        if "/specialists/" in sp and "skins_" in fn:
            gender = "female" if "female" in fn else "male"
            return f"characters/specialists/skins/{gender}.png"
        if "/specialists/" in sp:
            return f"references/source_sheets/kit_01_{fn}"
        return f"characters/specialists/{spec}/{fn}"

    if any(x in kn for x in ("idle_walk", "run_damage", "idle_greet", "idle_talk")) and entity in NPC_ENTITIES:
        role = entity
        if "/frames/" in sp:
            return f"npcs/{role}/animations/{fn}"
        return f"npcs/{role}/{fn}"

    if any(x in kn for x in ("idle_walk", "run_damage")) and entity not in MONSTER_ENTITIES:
        gender = "male" if "male" in kn or "blacksmith" not in kn else "female"
        if "female" in kn:
            gender = "female"
        elif "male" in kn:
            gender = "male"
        if "/frames/" in sp:
            state_dir = rec.animation_state or "misc"
            return f"characters/animations/{gender}/{state_dir}/{fn}"
        return f"characters/animations/{gender}/{fn}"

    # --- NPCS (before monsters — merchant/blacksmith also have *_directions kits) ---
    if entity in NPC_ENTITIES or "merchant" in kn or "blacksmith" in kn:
        role = entity or ("merchant" if "merchant" in kn else "blacksmith")
        if "8_directions" in kn and rec.direction:
            return f"npcs/{role}/directions/{rec.direction}.png"
        if rec.direction:
            return f"npcs/{role}/directions/{rec.direction}.png"
        if "/frames/" in sp:
            return f"npcs/{role}/animations/{fn}"
        return f"npcs/{role}/{fn}"

    # --- MONSTERS ---
    if entity in MONSTER_ENTITIES or "directions" in kn or "directions_actions" in kn:
        monster = entity
        if not monster and kit_name:
            monster = detect_entity_from_folder(kit_name)
        if rec.direction:
            state = rec.animation_state or "directions"
            if state == "directions":
                return f"monsters/{monster}/directions/{rec.direction}.png"
            return f"monsters/{monster}/actions/{state}/{rec.direction}.png"
        if rec.animation_state:
            if "/frames/" in sp:
                return f"monsters/{monster}/animations/{rec.animation_state}/{fn}"
            return f"monsters/{monster}/actions/{rec.animation_state}.png"
        if "idle_attack" in kn or "hit_defeated" in kn:
            if "/frames/" in sp:
                return f"monsters/{monster}/animations/{fn}"
            return f"monsters/{monster}/{fn}"
        return f"monsters/{monster}/{fn}"

    # --- UI ---
    ui_map = {
        "hud_frames": "ui/hud",
        "menu_frames": "ui/common",
        "touch_controls": "ui/touch",
        "raid_loot_ui": "ui/raid",
        "world_system_ui": "ui/map",
        "mobile_hud_components": "ui/hud",
        "menu_panel_shells": "ui/common",
        "ui_core_controls": "ui/common",
        "combat_hud_states": "ui/hud",
        "inventory_equipment_character_ui": "ui/inventory",
        "skills_specialist_progression_ui": "ui/skills",
        "quest_map_portal_raid_ui": "ui/quests",
        "mobile_ui": "ui/touch",
    }
    for key, dest in ui_map.items():
        if key in kn or key in sp:
            sub = Path(dest).name
            if "equipment" in fn:
                return f"ui/equipment/{fn}"
            if "inventory" in fn:
                return f"ui/inventory/{fn}"
            if "character" in fn:
                return f"ui/character/{fn}"
            if "target" in fn:
                return f"ui/target/{fn}"
            if "minimap" in fn:
                return f"ui/map/{fn}"
            if "quest" in fn or "dialog" in fn:
                return f"ui/quests/{fn}"
            if "raid" in fn or "dungeon" in fn or "portal" in fn:
                return f"ui/raid/{fn}"
            if "skill" in fn or "specialist" in fn:
                return f"ui/skills/{fn}"
            return f"{dest}/{fn}"

    # --- COMBAT / VFX ---
    if any(x in kn for x in ("vfx", "slash", "magic_support", "leaf_bloom")):
        vfx_name = kn.replace("_vfx", "").replace("_vfx_sequence", "")
        if "/frames/" in sp:
            return f"combat/vfx/{vfx_name}/frames/{fn}"
        return f"combat/vfx/{vfx_name}/{fn}"

    # --- ITEMS ---
    if any(x in kn for x in ("loot", "crafting", "chests", "resources_quests")):
        if "chest" in kn:
            return f"items/loot/{fn}"
        if "quest" in kn or "quest" in fn:
            return f"items/quest/{fn}"
        if any(x in fn for x in ("berry", "amber", "shard", "ore", "herb", "wood")):
            return f"items/materials/{fn}"
        return f"items/misc/{fn}"

    # --- WORLD ---
    world_routes = [
        (("ground_materials", "terrain_meadow", "seamless_terrain"), "world/terrain"),
        (("roads", "riverbank", "paths"), "world/roads"),
        (("water", "river", "pond", "ford", "footbridge"), "world/water"),
        (("elevation", "cliff", "ramp", "stair", "ledge", "raised"), "world/elevation"),
        (("vegetation", "trees", "plants", "woodland", "nebelbruch_vegetation"), "world/vegetation"),
        (("building", "cottage", "village", "inn", "workshop", "hainweiler"), "world/buildings"),
        (("props", "world_props", "village_life", "village_wilds"), "world/props"),
        (("portal", "checkpoint", "waypoint"), "world/portals"),
        (("dungeon", "raid_entrance", "mine", "cave", "ruin", "kupfermine", "kristallhoehle", "alte_ruinen"), "world/dungeons"),
        (("landmark", "nebelbruch_landmarks", "nightfall_biome"), "world/landmarks"),
        (("world_transitions",), "world/landmarks"),
    ]
    for keys, dest in world_routes:
        if any(k in kn for k in keys) or any(k in fn for k in keys):
            if "seamless_terrain" in sp:
                return f"world/terrain/seamless/{fn}"
            if "overlay" in fn:
                return f"world/terrain/overlays/{fn}"
            if "repeat" in fn:
                return f"world/terrain/materials/{fn}"
            return f"{dest}/{fn}"

    # kit 1 animation folder already handled
    if "/vfx/" in sp:
        return f"combat/vfx/{fn}"

    # fallback by kit number ranges
    if kit_num and 25 <= kit_num <= 29:
        return f"ui/common/{kit_num}_{fn}"
    if kit_num and 79 <= kit_num <= 83:
        return f"characters/equipment/{fn}"

    if rec.classification == "DOCUMENTATION":
        return ""

    # last resort
    return f"references/unclear/{kit_num or 0}_{kit_name}/{fn}" if kit_num else f"references/unclear/{fn}"


def _map_master_path(rec: FileRecord, kit_num: Optional[int], kit_name: str, entity: str, fn: str) -> str:
    """Route composite masters to provenance storage, never runtime identity."""
    kit_part = f"kit_{kit_num:02d}" if kit_num else "kit_unknown"
    role = Path(fn).stem.lower()
    source_role = "master" if role in {"master", "source_master"} else role
    identity = kit_name or entity or "unclassified"
    return f"references/source_sheets/{kit_part}_{identity}_{source_role}.png"


def enrich_record(rec: FileRecord) -> None:
    classify_file(rec)
    kit_suffix = rec.kit_folder.split("/")[-1] if rec.kit_folder else ""
    kit_num, kit_name = parse_kit_folder(kit_suffix) if kit_suffix else (rec.source_kit, "")
    rec.source_kit = kit_num or rec.source_kit
    entity = detect_entity_from_folder(kit_name) if kit_name else ""
    rec.entity_name = entity

    if rec.copy_to_production or rec.classification in {"MASTER", "SOURCE_SHEET", "PREVIEW", "REFERENCE"}:
        rec.canonical_path = map_canonical_path(rec)
        # set category from path
        if rec.canonical_path:
            parts = PurePosixPath(rec.canonical_path).parts
            rec.category = parts[0] if parts else ""
            rec.subcategory = parts[1] if len(parts) > 1 else ""
            rec.asset_type = "SOURCE_SHEET" if rec.classification == "MASTER" else rec.classification
            rec.status = "cataloged"
    else:
        rec.status = "skipped"


def load_semantic_overrides() -> dict[str, dict]:
    """Load reviewed semantic corrections that supersede source naming."""
    if not SEMANTIC_OVERRIDES.is_file():
        return {}
    payload = json.loads(SEMANTIC_OVERRIDES.read_text(encoding="utf-8"))
    overrides = payload.get("overrides", {})
    if not isinstance(overrides, dict):
        raise RuntimeError("SEMANTIC_OVERRIDES.json: overrides must be an object")
    return overrides


def apply_semantic_override(rec: FileRecord, overrides: dict[str, dict]) -> None:
    """Apply evidence-backed identity without trusting kit folders or filenames."""
    override = overrides.get(rec.source_path.replace("\\", "/"))
    if not override:
        return

    canonical_path = str(override.get("canonical_path", "")).replace("\\", "/")
    asset_type = str(override.get("asset_type", ""))
    if not canonical_path or not asset_type:
        raise RuntimeError(f"Incomplete semantic override for {rec.source_path}")

    rec.canonical_path = canonical_path
    rec.classification = asset_type
    rec.asset_type = asset_type
    parts = PurePosixPath(canonical_path).parts
    rec.category = parts[0] if parts else ""
    rec.subcategory = parts[1] if len(parts) > 1 else ""
    rec.entity_name = str(override.get("entity_name", ""))
    rec.direction = str(override.get("direction", ""))
    rec.animation_state = str(override.get("animation_state", ""))
    rec.copy_to_production = True
    rec.semantic_alias = bool(override.get("duplicate_alias", False))
    rec.status = "cataloged"
    note = str(override.get("notes", "")).strip()
    verification = str(override.get("verification", "")).strip()
    rec.notes = f"{verification}: {note}" if verification else note


def resolve_path_collisions(records: list[FileRecord]) -> None:
    """Ensure unique canonical paths for different content."""
    by_canonical: dict[str, list[FileRecord]] = defaultdict(list)
    for r in records:
        if r.canonical_path:
            by_canonical[r.canonical_path].append(r)

    for path, group in by_canonical.items():
        if len(group) <= 1:
            continue
        # group by hash
        by_hash: dict[str, list[FileRecord]] = defaultdict(list)
        for r in group:
            by_hash[r.sha256].append(r)
        if len(by_hash) == 1:
            # identical content — keep first, mark others as duplicate
            primary = next((r for r in group if not r.semantic_alias), group[0])
            for r in group:
                if r is primary:
                    continue
                r.status = "duplicate_of_primary"
                r.notes = f"same as {primary.canonical_path}"
                r.copy_to_production = False
            continue
        # Different content must never share a destination. Prefer semantic
        # source filenames; add archive identity only when those still clash.
        candidate_stems = [
            f"kit{r.source_kit or 0:02d}_{Path(r.source_path).stem}"
            for r in group
        ]
        candidate_counts = Counter(candidate_stems)
        for r in group:
            kit = r.source_kit or 0
            source_stem = Path(r.source_path).stem
            stem = f"kit{kit:02d}_{source_stem}"
            if candidate_counts[stem] > 1:
                archive = re.sub(r"[^a-z0-9]+", "_", Path(r.source_zip).stem.lower()).strip("_")
                stem = f"{archive}_{source_stem}"
            if any(
                other is not r
                and other.sha256 != r.sha256
                and Path(other.source_path).stem == source_stem
                and other.source_zip == r.source_zip
                for other in group
            ):
                stem = f"{stem}_{r.sha256[:8]}"
            suffix = Path(path).suffix
            parent = str(PurePosixPath(path).parent)
            new_path = f"{parent}/{stem}{suffix}"
            r.canonical_path = new_path
            r.notes = "path collision resolved with source identity"


def copy_production_files(records: list[FileRecord]) -> set[str]:
    copied: set[str] = set()
    for r in records:
        if not r.canonical_path or not r.copy_to_production:
            continue
        if r.status == "duplicate_of_primary":
            continue
        dest = ASSET_GAME / r.canonical_path
        if dest.exists() and r.canonical_path in copied:
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(r.work_path, dest)
        copied.add(r.canonical_path)
        r.status = "copied"
    return copied


def build_duplicate_report(records: list[FileRecord]) -> dict:
    by_hash: dict[str, list[FileRecord]] = defaultdict(list)
    for r in records:
        if r.ext in {".png", ".webp", ".jpg"}:
            by_hash[r.sha256].append(r)
    groups = {h: g for h, g in by_hash.items() if len(g) > 1}
    return groups


def build_animation_matrix(records: list[FileRecord], entity_type: str) -> dict:
    """Build direction x state matrix for characters or monsters."""
    entities: dict[str, dict] = defaultdict(lambda: defaultdict(lambda: defaultdict(str)))

    for r in records:
        if r.classification not in {
            "PRODUCTION_DIRECTION", "PRODUCTION_FRAME", "PRODUCTION_SINGLE",
            "DIRECTIONAL_SPRITE", "ANIMATION_FRAME", "ACTION_ASSET",
            "MASTER", "SOURCE_SHEET",
        }:
            continue
        entity = r.entity_name
        if not entity:
            continue

        if entity_type == "monster" and entity not in MONSTER_ENTITIES:
            continue
        if entity_type == "player" and entity not in {"male", "female", "base_male", "base_female"}:
            if "base_male" in r.source_path or "base_female" in r.source_path:
                entity = "male" if "male" in r.source_path and "female" not in r.source_path.split("male")[0] else "female"
            elif "male" in (r.kit_folder or ""):
                entity = "male" if "female" not in (r.kit_folder or "") else "female"
            else:
                continue
        if entity_type == "npc" and entity not in NPC_ENTITIES:
            continue

        # normalize entity names for player
        if entity in ("base_male",):
            entity = "male"
        if entity in ("base_female",):
            entity = "female"

        direction = r.direction or "*"
        state = r.animation_state or ""
        if not state and r.classification == "PRODUCTION_DIRECTION":
            state = "idle"
        if not state and "directions" in (r.kit_folder or ""):
            state = "directions"
        if not state and "locomotion" in (r.kit_folder or ""):
            state = Path(r.filename).stem.split("_")[0] if "_" in r.filename else "locomotion"
        if not state and "/frames/" in r.source_path:
            state = r.animation_state or "animation"
        if not state:
            state = "static"

        if r.classification == "SOURCE_SHEET" or r.classification == "MASTER":
            mark = "SHEET_ONLY"
        elif r.classification in {"PRODUCTION_FRAME", "ANIMATION_FRAME"}:
            mark = "PARTIAL" if not r.direction else "AVAILABLE"
        elif r.classification in {"PRODUCTION_DIRECTION", "DIRECTIONAL_SPRITE"}:
            mark = "AVAILABLE"
        else:
            mark = "PARTIAL"

        key = f"{direction}|{state}"
        prev = entities[entity].get(key, "")
        if prev in ("", "MISSING"):
            entities[entity][key] = mark
        elif prev == "PARTIAL" and mark == "AVAILABLE":
            entities[entity][key] = mark

    return entities


def write_character_animation_matrix(records: list[FileRecord], path: Path) -> None:
    lines = ["# Character Animation Matrix", "", f"Generated: {datetime.now(timezone.utc).isoformat()}", ""]
    for label, etype in [("Player Base (Male/Female)", "player"), ("NPC", "npc")]:
        lines.append(f"## {label}")
        lines.append("")
        matrix = build_animation_matrix(records, etype)
        for entity in sorted(matrix.keys()):
            lines.append(f"### {entity}")
            lines.append("")
            lines.append("| Direction | " + " | ".join(ANIM_STATES) + " |")
            lines.append("|" + "---|" * (len(ANIM_STATES) + 1))
            for dir in DIRECTIONS + ["*"]:
                row = [dir]
                for st in ANIM_STATES:
                    val = "MISSING"
                    for r in records:
                        pass
                    # scan records for this entity
                    val = _matrix_cell(records, entity, dir, st, etype)
                    row.append(val)
                if all(c == "MISSING" for c in row[1:]):
                    continue
                lines.append("| " + " | ".join(row) + " |")
            lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def _matrix_cell(records, entity, direction, state, entity_type) -> str:
    found_dir = False
    found_sheet = False
    found_partial = False
    frame_count = 0
    for r in records:
        ent = r.entity_name
        if entity_type == "player":
            if ent in ("base_male",):
                ent = "male"
            if ent in ("base_female",):
                ent = "female"
            if ent not in (entity,) and entity not in r.source_path:
                if entity == "male" and "base_male" not in r.source_path and "/56_" not in r.source_path and "/54_" not in r.source_path and "/64_" not in r.source_path and "/65_" not in r.source_path:
                    continue
                if entity == "female" and "base_female" not in r.source_path and "/55_" not in r.source_path and "/57_" not in r.source_path and "/66_" not in r.source_path and "/67_" not in r.source_path:
                    if "female" not in r.source_path:
                        continue
        elif entity_type == "npc" and ent != entity:
            if entity not in r.source_path:
                continue
        elif entity_type == "monster" and ent != entity:
            continue

        if r.classification in {"SOURCE_SHEET", "MASTER"}:
            if state in r.source_path or state in r.filename or (state == "idle" and "direction" in r.source_path):
                found_sheet = True
            continue

        d = r.direction or "*"
        st = r.animation_state or ""
        fn = r.filename.lower()
        if not st:
            if "walk" in fn:
                st = "walk"
            elif "run" in fn:
                st = "run"
            elif "idle" in fn:
                st = "idle"
            elif "attack" in fn:
                st = "attack"
            elif "hit" in fn:
                st = "hit"
            elif "defeat" in fn:
                st = "defeated"
            elif r.classification in {"PRODUCTION_DIRECTION", "DIRECTIONAL_SPRITE"}:
                st = "idle"

        if direction != "*" and d != direction:
            continue
        if direction == "*" and d != "*":
            continue
        st_match = st == state or (state == "idle" and st in ("idle", "idle_ready", ""))
        if st_match or (state in fn):
            if r.classification in {"PRODUCTION_DIRECTION", "DIRECTIONAL_SPRITE"} and direction != "*" and d == direction:
                found_dir = True
            elif r.classification in {"PRODUCTION_FRAME", "ANIMATION_FRAME"}:
                found_partial = True
                frame_count += 1
            elif r.classification in {"PRODUCTION_DIRECTION", "DIRECTIONAL_SPRITE"}:
                found_dir = True
            elif r.classification in {"PRODUCTION_SINGLE", "ACTION_ASSET"} and state in fn:
                found_partial = True

    if found_dir:
        return "AVAILABLE"
    if direction == "*" and frame_count >= 2:
        return "AVAILABLE"
    if found_partial:
        return "PARTIAL"
    if found_sheet:
        return "SHEET_ONLY"
    return "MISSING"


def write_monster_animation_matrix(records: list[FileRecord], path: Path) -> None:
    lines = ["# Monster Animation Matrix", "", f"Generated: {datetime.now(timezone.utc).isoformat()}", ""]
    monsters = sorted(MONSTER_ENTITIES)
    # also detect from records
    for r in records:
        if r.entity_name in MONSTER_ENTITIES:
            pass
    for monster in monsters:
        lines.append(f"## {monster}")
        lines.append("")
        lines.append("| Direction | idle | walk | run | attack | cast | hit | defeated |")
        lines.append("|---|---|---|---|---|---|---|---|")
        for dir in DIRECTIONS + ["*"]:
            row = [dir]
            for st in ["idle", "walk", "run", "attack", "cast", "hit", "defeated"]:
                row.append(_matrix_cell(records, monster, dir, st, "monster"))
            if all(c == "MISSING" for c in row[1:]):
                continue
            lines.append("| " + " | ".join(row) + " |")
        lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def write_world_readiness(records: list[FileRecord], path: Path) -> None:
    categories = {
        "terrain": ["world/terrain"],
        "roads": ["world/roads"],
        "water": ["world/water"],
        "buildings": ["world/buildings"],
        "vegetation": ["world/vegetation"],
        "props": ["world/props"],
        "height transitions": ["world/elevation"],
        "portals": ["world/portals"],
        "dungeons": ["world/dungeons"],
        "collision-relevant shapes": ["world/elevation", "world/buildings", "world/terrain"],
        "occlusion suitability": ["world/buildings", "world/vegetation", "world/props"],
    }
    counts = defaultdict(int)
    sheet_only = defaultdict(int)
    sheet_keywords = {
        "vegetation": ("trees", "plants", "vegetation", "woodland", "harvestable"),
        "props": ("props", "world_props", "village_life", "village_wilds"),
        "dungeons": ("ruinen", "kupfermine", "kristallhoehle", "dungeon", "mine", "cave"),
    }
    for r in records:
        if not r.canonical_path:
            continue
        sp = (r.source_path + " " + (r.kit_folder or "")).lower()
        for cat, prefixes in categories.items():
            path_match = any(r.canonical_path.startswith(p) for p in prefixes)
            kw_match = any(k in sp for k in sheet_keywords.get(cat, ()))
            if path_match or (r.classification == "SOURCE_SHEET" and kw_match):
                if r.classification == "SOURCE_SHEET":
                    sheet_only[cat] += 1
                elif r.classification in {
                    "PRODUCTION_SINGLE", "PRODUCTION_DIRECTION", "PRODUCTION_FRAME",
                    "WORLD_ASSET", "DIRECTIONAL_SPRITE", "ANIMATION_FRAME",
                    "ACTION_ASSET", "MASTER",
                }:
                    counts[cat] += 1

    lines = [
        "# World Readiness (2.5D Oblique)",
        "",
        f"Generated: {datetime.now(timezone.utc).isoformat()}",
        "",
        "Reference: `WORLD_CAMERA_SPEC.md` from kit 36-37 (extracted to references).",
        "",
        "| Category | Status | Production Assets | Sheet/Reference Only | Notes |",
        "|---|---|---:|---:|---|",
    ]
    notes_map = {
        "terrain": "Seamless materials + overlays from kits 30, 38; meadow sheets in kit 1",
        "roads": "Cobble/earth/meadow transitions kit 30; path sheets kit 1-2",
        "water": "River edges, fords, bridges kits 30, 49-50",
        "buildings": "Village modules kits 5, 31, 39, 49, 51; layered cottage kit 45",
        "vegetation": "Trees, plants kits 3-4, 11, 31, 40",
        "props": "World props kits 6, 31, 40",
        "height transitions": "Cliffs, ramps, stairs kits 36, 44, 49; elevation connectors",
        "portals": "Active/inactive arches, waypoints kit 52",
        "dungeons": "Mine, cave, raid entrances kit 53 + dungeon sheets 13-15",
        "collision-relevant shapes": "Individual pieces present; collision not authored yet",
        "occlusion suitability": "Buildings/trees have visible sides; needs in-engine test",
    }
    for cat in categories:
        prod = counts[cat]
        sheets = sheet_only[cat]
        if prod >= 8:
            status = "READY"
        elif prod >= 3 or sheets >= 1:
            status = "PARTIAL"
        else:
            status = "MISSING"
        lines.append(f"| {cat} | {status} | {prod} | {sheets} | {notes_map.get(cat, '')} |")

    lines.extend([
        "",
        "## 2.5D Vertical Slice Assessment",
        "",
        "- **READY**: Ground tiles, roads, basic water, village buildings, trees/props, elevation modules, portals",
        "- **PARTIAL**: Nightfall biome, dungeon entrance variety, seamless terrain blending (needs engine tiling)",
        "- **MISSING**: Authored collision polygons, navigation meshes, height-map integration (out of scope)",
    ])
    path.write_text("\n".join(lines), encoding="utf-8")


def write_kit_coverage(records: list[FileRecord], path: Path) -> None:
    kits: dict[int, list[FileRecord]] = defaultdict(list)
    for r in records:
        if r.source_kit is not None:
            kits[r.source_kit].append(r)
    lines = ["# Kit Coverage (1–93)", "", f"Generated: {datetime.now(timezone.utc).isoformat()}", ""]
    lines.append("| Kit | Source Files | Production Copies | Classifications |")
    lines.append("|---:|---:|---:|---|")
    for k in range(1, 94):
        group = kits.get(k, [])
        prod = sum(1 for r in group if r.copy_to_production and r.status in {"copied", "cataloged"})
        cls = defaultdict(int)
        for r in group:
            cls[r.classification] += 1
        cls_str = ", ".join(f"{a}:{n}" for a, n in sorted(cls.items()))
        lines.append(f"| {k} | {len(group)} | {prod} | {cls_str or '—'} |")
    missing = [k for k in range(1, 94) if k not in kits]
    lines.extend(["", f"**Missing kits:** {missing if missing else 'None — full coverage 1–93'}", ""])
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    print("=== ASSET FOUNDATION 01 ===")
    print(f"Project: {PROJECT_ROOT}")

    # Phase 0
    if not ASSET_IMPORT.is_dir():
        raise SystemExit("_asset_import not found")

    zips = sorted([p for p in ASSET_IMPORT.glob("*.zip")])
    print(f"Found {len(zips)} ZIP archives")
    semantic_overrides_text = (
        SEMANTIC_OVERRIDES.read_text(encoding="utf-8")
        if SEMANTIC_OVERRIDES.is_file()
        else ""
    )
    semantic_overrides = load_semantic_overrides()

    if ASSET_GAME.exists():
        print("Rebuilding assets/game (catalog + production copies) ...")
        shutil.rmtree(ASSET_GAME)
    ASSET_GAME.mkdir(parents=True)

    CATALOG.mkdir(parents=True, exist_ok=True)
    if semantic_overrides_text:
        SEMANTIC_OVERRIDES.write_text(semantic_overrides_text, encoding="utf-8")

    # Phase 1 — extract
    if ASSET_WORK.exists():
        print("Clearing previous _asset_work ...")
        shutil.rmtree(ASSET_WORK)
    ASSET_WORK.mkdir(parents=True)

    all_records: list[FileRecord] = []
    broken_zips: list[str] = []

    for zp in zips:
        print(f"Extracting {zp.name} ...")
        try:
            names = safe_extract_zip(zp, ASSET_WORK)
        except Exception as e:
            broken_zips.append(f"{zp.name}: {e}")
            continue
        for name in names:
            work_path = ASSET_WORK / name.replace("/", os.sep)
            if not work_path.is_file():
                continue
            parts = PurePosixPath(name).parts
            source_kit, kit_folder = detect_source_kit(name, parts)
            ext = work_path.suffix.lower()
            if ext in SKIP_COPY_EXTENSIONS:
                continue
            size = work_path.stat().st_size
            if size == 0:
                continue
            rec = FileRecord(
                source_zip=zp.name,
                source_path=name,
                work_path=work_path,
                source_kit=source_kit,
                kit_folder=kit_folder,
                filename=work_path.name,
                ext=ext,
                sha256=sha256_file(work_path),
                size=size,
            )
            enrich_record(rec)
            apply_semantic_override(rec, semantic_overrides)
            all_records.append(rec)

    print(f"Indexed {len(all_records)} source files")

    # Phase 6 — duplicates
    dup_groups = build_duplicate_report(all_records)
    resolve_path_collisions(all_records)

    # Phase 4 — copy
    copied = copy_production_files(all_records)
    print(f"Copied {len(copied)} canonical production files")

    # Copy world camera spec to references
    for spec_name in ("WORLD_CAMERA_SPEC.md",):
        for p in ASSET_WORK.rglob(spec_name):
            dest = ASSET_GAME / "references" / spec_name
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(p, dest)

    # Phase 10 — catalogs
    manifest_path = CATALOG / "ASSET_MANIFEST.csv"
    mapping_path = CATALOG / "SOURCE_MAPPING.csv"

    fieldnames = [
        "asset_id", "canonical_path", "category", "subcategory", "asset_type",
        "entity_name", "direction", "animation_state", "frame",
        "source_zip", "source_path", "sha256", "status", "notes",
    ]
    asset_id = 0
    with open(manifest_path, "w", newline="", encoding="utf-8") as mf:
        writer = csv.DictWriter(mf, fieldnames=fieldnames)
        writer.writeheader()
        for r in sorted(all_records, key=lambda x: (x.canonical_path or "", x.source_path)):
            asset_id += 1
            writer.writerow({
                "asset_id": f"A{asset_id:05d}",
                "canonical_path": r.canonical_path,
                "category": r.category,
                "subcategory": r.subcategory,
                "asset_type": r.classification,
                "entity_name": r.entity_name,
                "direction": r.direction,
                "animation_state": r.animation_state,
                "frame": r.frame,
                "source_zip": r.source_zip,
                "source_path": r.source_path,
                "sha256": r.sha256,
                "status": r.status,
                "notes": r.notes,
            })

    with open(mapping_path, "w", newline="", encoding="utf-8") as sf:
        writer = csv.DictWriter(sf, fieldnames=[
            "canonical_path", "source_zip", "source_path", "source_kit", "sha256",
        ])
        writer.writeheader()
        for r in all_records:
            if r.canonical_path:
                writer.writerow({
                    "canonical_path": r.canonical_path,
                    "source_zip": r.source_zip,
                    "source_path": r.source_path,
                    "source_kit": r.source_kit or "",
                    "sha256": r.sha256,
                })

    write_kit_coverage(all_records, CATALOG / "KIT_COVERAGE.md")
    write_character_animation_matrix(all_records, CATALOG / "CHARACTER_ANIMATION_MATRIX.md")
    write_monster_animation_matrix(all_records, CATALOG / "MONSTER_ANIMATION_MATRIX.md")
    write_world_readiness(all_records, CATALOG / "WORLD_READINESS.md")

    # DUPLICATES.md
    dup_lines = ["# Duplicate Report", "", f"Exact duplicate groups: {len(dup_groups)}", ""]
    for i, (h, group) in enumerate(sorted(dup_groups.items(), key=lambda x: -len(x[1]))[:100], 1):
        dup_lines.append(f"## Group {i} ({len(group)} files, sha256 `{h[:16]}...`)")
        for r in group[:10]:
            dup_lines.append(f"- `{r.source_zip}` → `{r.source_path}`")
        if len(group) > 10:
            dup_lines.append(f"- ... and {len(group)-10} more")
        dup_lines.append("")
    (CATALOG / "DUPLICATES.md").write_text("\n".join(dup_lines), encoding="utf-8")

    # SOURCE_SHEETS.md
    sheets = [r for r in all_records if r.classification in {"SOURCE_SHEET", "MASTER"}]
    sl = ["# Source Sheets", "", "Do NOT use as single in-game sprites without slicing.", "", f"Total: {len(sheets)}", ""]
    for r in sorted(sheets, key=lambda x: x.source_path):
        sl.append(f"- `{r.canonical_path}` ← `{r.source_zip}:{r.source_path}`")
    (CATALOG / "SOURCE_SHEETS.md").write_text("\n".join(sl), encoding="utf-8")

    # MISSING_OR_UNCLEAR.md
    unclear = [r for r in all_records if r.classification == "UNKNOWN" or (r.canonical_path or "").startswith("references/unclear/")]
    ul = ["# Missing or Unclear", "", f"Total flagged: {len(unclear)}", ""]
    for r in unclear:
        ul.append(f"- `{r.source_zip}:{r.source_path}` — {r.classification} — {r.notes}")
    (CATALOG / "MISSING_OR_UNCLEAR.md").write_text("\n".join(ul), encoding="utf-8")

    # ASSET_CATALOG.md summary
    cls_counts = defaultdict(int)
    cat_counts = defaultdict(int)
    for r in all_records:
        cls_counts[r.classification] += 1
        if r.category:
            cat_counts[r.category] += 1
    catalog_md = [
        "# Asset Catalog",
        "",
        f"Generated: {datetime.now(timezone.utc).isoformat()}",
        "",
        "## Summary",
        f"- Source files indexed: **{len(all_records)}**",
        f"- Canonical production files: **{len(copied)}**",
        f"- ZIP archives: **{len(zips)}**",
        f"- Broken archives: **{len(broken_zips)}**",
        "",
        "## Classification",
        "",
    ]
    for k, v in sorted(cls_counts.items(), key=lambda x: -x[1]):
        catalog_md.append(f"- {k}: {v}")
    catalog_md.extend(["", "## Category", ""])
    for k, v in sorted(cat_counts.items(), key=lambda x: -x[1]):
        catalog_md.append(f"- {k}: {v}")
    (CATALOG / "ASSET_CATALOG.md").write_text("\n".join(catalog_md), encoding="utf-8")

    # README.md
    readme = f"""# Game Asset Library (`assets/game`)

Canonical production asset library for the mobile MMORPG.

- **Created:** ASSET FOUNDATION 01 ({datetime.now(timezone.utc).date()})
- **Source:** BRAMBLE kits 1–93 from `_asset_import/` (unchanged raw archive)
- **Work area:** `_asset_work/` (extraction staging, safe to delete after verification)

## Structure

- `characters/` — player bases, animations, equipment, specialists
- `monsters/` — monster directions and action assets
- `npcs/` — NPC directional and animation assets
- `world/` — terrain, buildings, props, portals, dungeons
- `items/` — loot, materials, quest items
- `combat/` — skills, VFX, projectiles
- `ui/` — HUD, touch controls, menus
- `references/` — source sheets, masters, concepts (not direct production sprites)
- `_catalog/` — manifests, mappings, audits

## Rules

1. Do not reference BRAMBLE kit paths in game code — use canonical paths only.
2. Full provenance is in `_catalog/SOURCE_MAPPING.csv`.
3. Source sheets must be sliced before use as individual sprites.

See `_catalog/ASSET_CATALOG.md` for full inventory.
"""
    (CATALOG / "README.md").write_text(readme, encoding="utf-8")

    # Validation summary to stdout
    kits_found = sorted({r.source_kit for r in all_records if r.source_kit is not None})
    missing_kits = [k for k in range(1, 94) if k not in kits_found]
    collisions = sum(1 for r in all_records if "collision" in r.notes)
    no_mapping = sum(1 for r in all_records if r.copy_to_production and not r.canonical_path)

    print("\n=== VALIDATION ===")
    print(f"Kits 1-93: {'COMPLETE' if not missing_kits else missing_kits}")
    print(f"Classifications: {dict(cls_counts)}")
    print(f"Production copies: {len(copied)}")
    print(f"Duplicate groups: {len(dup_groups)}")
    print(f"Path collisions resolved: {collisions}")
    print(f"Broken zips: {broken_zips or 'none'}")
    print(f"Unknown: {cls_counts.get('UNKNOWN', 0)}")
    print(f"Assets without mapping: {no_mapping}")
    print("Done.")


if __name__ == "__main__":
    main()
