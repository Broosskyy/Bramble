# M04 — Character, Inventory & RPG Foundation + Production UI Pass 01

**Milestone:** M04  
**Baseline HEAD:** `13eb1298a662fc656b59b7069ac08b3ba387027d` (M03.1 complete)  
**Gate date:** 2026-09-16  
**Branch:** `main` · **Remote:** `origin`

---

## A. Existing RPG Audit

| System | Current Implementation | Action | M04 Result |
|--------|------------------------|--------|------------|
| GameState | M03 HUD/quest mirror; loot/XP hooks | EXTEND | Delegates XP/loot to `character_state_service`; mirrors canonical view for HUD |
| PlayerController | Movement, interact, combat intents | KEEP | Skill readiness per slot unchanged |
| HP/MP | Split across authority + game_state | FIX | Canonical HP/MP from stat pipeline via character state |
| XP/Level | M03 moorling rewards + V11 progression stubs | EXTEND | Data-driven thresholds in `character_progression.json` |
| M03 Combat | Targeting + runtime service | KEEP | Consumes stat-based damage + MP/cooldown skills |
| Inventory | V11 `inventory_service` + authority stacks | EXTEND | Bridged through `character_state_service` |
| Loot | M03 pickups | EXTEND | Pickups mutate authority inventory |
| Equipment | V11 `equipment_service` authority slots | EXTEND | M04 slot map + validation via item `allowed_slot` |
| Equipment Rig | Legacy `equipment_rig.gd` + registry v4 paths | FIX | Production overlay via `production_equipment_visual.gd`; registry mismatch documented |
| Item definitions | Mixed M03 strings + partial JSON | FIX | Canonical `data/content/items.json` |
| Registries | `content_db`, equipment registry v4 | KEEP/FIX | Items/skills via content_db; v4 paths not used at runtime |
| Skills | M03 `cut` only in combat | EXTEND | `cut` + `wild_slash` with full schema hooks |
| Skillbar | Single skill button | EXTEND | 3-slot bar from character state |
| Persistence | V11 `character_repository` user:// JSON | EXTEND | Full RPG fields persisted on mutation |
| Authority | `player_authority` peer states | KEEP | Mutations routed through services |
| ProductionHUD | M03 layout | EXTEND | MP/XP, nav, target panel, skill cooldowns |
| UI assets | `assets/game/ui/*` kits | EXTEND | Inventory/character panels use production textures |

**Equipment registry/rig path mismatch (resolved for M04):**

- Legacy `data/equipment_registry_v4.json` references `assets/equipment_items/` (missing).
- M04 runtime uses `data/content/items.json` + `assets/game/characters/equipment/` icons.
- Weapon world overlay resolves `assets/equipment/weapons/{key}.png` with game_tex fallback.

---

## B. Character State

Single canonical bridge: `scripts/character_state_service.gd` (`BrambleCharacterStateService`).

Fields exposed via `get_character_view()`:

- **Identity:** `character_id`, `display_name`
- **Progression:** `level`, `xp`, `xp_to_next_level`, `available_stat_points`, `available_skill_points`
- **Base stats:** vitality, strength, defense, magic, resistance, speed (in `base_stats` + `final_stats`)
- **Derived stats:** max_hp, max_mp, physical_attack, magic_attack, physical_defense, magic_defense, move_speed, attack_speed
- **Resources:** hp, mp (current)
- **References:** inventory[], equipment{}, known_skills[], unlocked_skills[], skillbar[]

UI reads this view; UI does not own RPG state.

---

## C. Stat Pipeline

`scripts/stat_pipeline_service.gd`:

```
BASE CHARACTER + LEVEL GROWTH + EQUIPMENT + MODIFIER_HOOKS = FINAL STATS → DERIVED COMBAT STATS
```

- Level growth from `character_progression.json`
- Equipment modifiers summed from equipped item definitions
- `_modifier_hook_totals()` empty struct for future class/buff/pet/set hooks
- `apply_derived_to_state()` writes max_hp/max_mp/derived_stats back to authority

---

## D. XP / Level

- Config: `data/content/character_progression.json`
- `max_level`: 30
- `qa_xp_multiplier`: 0.35 (fast QA level-ups)
- Level-up rewards: +2 stat points, +1 skill point per level
- Moorling kills → `game_state.grant_xp` → `character_state_service.grant_xp`
- HUD toast on `level_up` signal

---

## E. Items

Canonical definitions in `data/content/items.json`.

Every item: stable `item_id`, display_name, description, category, rarity, icon, stackable, max_stack, sell_value, tradeable, droppable, required_level.

Categories: EQUIPMENT, CONSUMABLE, MATERIAL, QUEST, TOKEN, MISC.

M03 herb/ore/gold migrated to MATERIAL/MISC entries.

Test equipment pool: rusty_blade, forest_blade, leather_vest, padded_coat, trail_gloves, trail_boots, moss_ring (accessory), potion.

---

## F. Rarity

Centralized in item data + `content_db.rarity_color()`:

COMMON · UNCOMMON · RARE · EPIC · LEGENDARY

Controls UI modulate colors in inventory grid and detail panel.

---

## G. Inventory

- Capacity: 28 slots
- Stacks via `inventory_service` (item_id + qty)
- Mutations: add_item, remove_item, owns, can_add
- M03 loot pickup → `character_state_service.add_loot`
- Persistence via authority → character_repository

---

## H. Equipment

M04 slots → authority slots:

| M04 | Authority |
|-----|-----------|
| WEAPON | weapon |
| ARMOR | chest |
| GLOVES | hands |
| BOOTS | feet |
| HEAD | head |
| ACCESSORY_1 | accessory |
| ACCESSORY_2 | offhand |

Flow: validate item → level → slot → remove from inventory → equip → return replaced item → recalculate → visual refresh.

---

## I. Equipment Visual Rig

`scripts/production_equipment_visual.gd`:

| Visual | Status |
|--------|--------|
| Weapon overlay (Sprite2D on player) | **SUPPORTED** — `assets/equipment/weapons/*.png` or game_tex fallback |
| Armor/clothing sprite swap | **FALLBACK** — stats only; no body swap yet |
| Registry v4 body rig | **MISSING_PRODUCTION_ART** — paths not wired in production mode |

Stats function independently of visual availability.

---

## J. Character UI

Production panel (`production_rpg_ui.gd` → Character tab):

- Name, level, XP, HP/MP, gold
- Derived combat stats (attack, magic, defense, speed)
- Stat point allocation buttons (when points available)
- Skillbar assignment labels (M04 minimal)

Landscape: left summary + right inventory/character tabs.  
Portrait: full-width panel with adjusted anchors.

---

## K. Inventory UI

Production MMORPG panel using:

- `ui/character/character_stats_panel.png`
- `ui/inventory/kit76_inventory_panel.png`
- `ui/inventory/item_detail_tooltip.png`

Category tabs: ALL, WEAPONS, ARMOR, ACCESSORIES, CONSUMABLES, MATERIALS, QUEST.

Grid with rarity tint; detail panel with contextual actions.

---

## L. Item Comparison

Detail panel shows **AKTUELL vs GEWÄHLT** stat modifier deltas when selecting unequipped gear in the same slot as currently worn item.

Capture: forest_blade equipped, rusty_blade selected for comparison.

---

## M. Stat Allocation

`allocate_stat(stat_name)` — authority-side mutation, requires `available_stat_points > 0`.

Character screen shows vit/str/def/mag/res/spd buttons when points available.

---

## N. Skill Definitions

`data/content/skills.json` — canonical fields on M04 skills:

- skill_id, display_name, description, icon, skill_type, target_type
- resource_cost, cooldown, range, base_power, scaling, required_level
- class_requirement, form_requirement (empty hooks)

---

## O. Skill Progression

- known_skills vs unlocked_skills
- Level-based auto-unlock via `_unlock_skills_for_level`
- Skill points: `unlock_skill_with_points()` (manual unlock path)
- Skillbar: `assign_skillbar(slot, skill_id)`

M04 pool: cut (L1), wild_slash (L2 unlock).

---

## P. Skillbar

`production_hud.gd`: 3 skill buttons + cooldown overlay label.

Skills read from character state skillbar; MP cost + cooldown enforced in `combat_runtime_service`.

---

## Q. HUD Evolution

Toward Visual Master gameplay layout:

- Top-left: player HP/MP/level panel
- Top-center: target panel (contextual — only when target exists)
- Top-right: minimap + currencies area
- Bottom-left: joystick
- Bottom-right: attack + skill cluster
- Bottom nav: Inventar / Charakter / Quest / Social placeholders
- Quest tracker: compact right-side panel

---

## R. Portrait UI

Responsive relayout via `orientation_service` — not a shrunk landscape.

Inventory/character panels reflow; HUD touch targets repositioned.

---

## S. Landscape UI

Two-region inventory composition: character summary left, grid + categories right, detail column.

---

## T. Persistence

Saved to `user://bramble_v11_characters.json` via V11 character_repository:

character identity, level, xp, base_stats, stat/skill points, inventory, equipment, known/unlocked skills, skillbar.

`save_now()` called at end of M04 capture flow; bootstrap reload merges saved fields on next run.

---

## U. Authority Boundary

| Authority-owned | Client presentation |
|-----------------|---------------------|
| XP, level, stat allocation | Panel open/close |
| Inventory/equipment mutations | Tab/category filter |
| Effective combat stats | Selected item |
| Skill unlocks/assignment | Sorting (future) |
| Currency | UI layout state |

Offline routes through local authority abstraction — not client-authoritative RPG.

---

## V. Network / MTU

**Before M04:** full `pa.snapshot()` in 10 Hz world sync ≈ **3217 bytes** (2 players + 8 enemies, representative RPG-inflated state).

**After M04:** `pa.snapshot_lite()` — position, facing, hp, level only ≈ **737 bytes** for same scene.

Inventory/equipment/skills **not** appended to frequent world snapshots.

Future direction: delta snapshots, interest management, reliable character-state RPCs, inventory transaction messages.

---

## W. Runtime QA

| ID | Test | Result |
|----|------|--------|
| A | Character initialization | PASS |
| B | XP gain | PASS |
| C | Level up | PASS |
| D | Stat point award | PASS |
| E | Stat allocation | PASS |
| F | Inventory add | PASS |
| G | Inventory remove | PASS |
| H | Stack behavior | PASS |
| I | Capacity | PASS |
| J | Equipment validation | PASS |
| K | Equip | PASS |
| L | Unequip | PASS |
| M | Equipment replacement | PASS |
| N | Stat recalculation | PASS |
| O | Equipment visual | PASS (weapon overlay) |
| P | Inventory landscape | PASS |
| Q | Inventory portrait | PASS |
| R | Character landscape | PASS |
| S | Character portrait | PASS |
| T | Item comparison | PASS |
| U | Skill unlock | PASS (level-based) |
| V | Skill assignment | PARTIAL (labels; bar pre-seeded) |
| W | Skill execution | PASS |
| X | MP/resource cost | PASS |
| Y | Cooldown | PASS |
| Z | Save/load | PASS (repository persist + merge on bootstrap) |
| AA | M03 combat regression | PASS (smoke test) |
| AB | Multiplayer minimum | PASS (M03.1 E2E re-run at delivery) |

---

## X. Visual Master Comparison

Compared live M04 captures against the four Visual Masters (reference only — not pixel targets).

| Aspect | Assessment |
|--------|------------|
| HUD hierarchy | **MATCHES DIRECTION** — portrait/level/HP/MP top-left; target center; skills bottom |
| World readability | **DIFFERS ACCEPTABLY** — M03.1 occlusion fixes retained; some canopy density remains |
| Portrait layout | **MATCHES DIRECTION** — vertical HUD reflow, full-width inventory panel |
| Landscape layout | **MATCHES DIRECTION** — two-region inventory, combat HUD grouping |
| Inventory hierarchy | **MATCHES DIRECTION** — character + grid + detail; production panel assets |
| Equipment readability | **DIFFERS ACCEPTABLY** — slot labels minimal; comparison in detail panel |
| Character prominence | **MATCHES DIRECTION** — left summary with stats |
| Skillbar usability | **DIFFERS ACCEPTABLY** — 3 slots with cooldown text; no drag-assign UI |
| Touch target sizes | **MATCHES DIRECTION** — joystick/attack/skill buttons ≥44px |
| Panel density | **MATCHES DIRECTION** — MMORPG density without debug windows |

**MISSING PRODUCTION ASSET:** dedicated equipment slot frame art per slot; armor body visual rig; skill-specific icon art (shared skill_button.png).

---

## Y. Evidence

```
artifacts/m04/
  gameplay_landscape.png
  gameplay_portrait.png
  inventory_landscape.png
  inventory_portrait.png
  character_landscape.png
  character_portrait.png
  equipment_comparison.png
  equipment_equipped.png
  skillbar_landscape.png
  skillbar_portrait.png
  level_up.png

artifacts/live/
  latest_landscape.png
  latest_portrait.png
  latest_gameplay.png
  LIVE_BUILD.md
```

Capture command: `Godot --path BRAMBLE_GAME res://scenes/main.tscn --m04-capture`

---

## Z. Remaining Debt

- Full skill assignment UI (drag/tap to slot) deferred
- Dedicated equipment slot panel art per body slot
- Armor/clothing world visual (body swap rig)
- Equipment registry v4 cleanup / deprecation
- Full combat replication on clients (Authority milestone)
- PostgreSQL persistence migration
- Item drop action UI
- Social/Shop nav placeholders only

---

## AA. Recommended M05

1. **Authority & Combat Replication** — server-validated combat intents, enemy state sync
2. **Class / Job selection** — activate class_requirement hooks
3. **Crafting foundation** — MATERIAL category → recipe pipeline
4. **Equipment slot UI polish** — dedicated slot frames + body rig integration
5. **Quest journal production UI** — replace placeholder nav tab
6. **Interest management** — further snapshot reduction for larger worlds

---

## Final Gates

| Gate | Status |
|------|--------|
| CHARACTER_RPG_FOUNDATION | **PASS** |
| INVENTORY_FOUNDATION | **PASS** |
| EQUIPMENT_FOUNDATION | **PASS** |
| STAT_PIPELINE | **PASS** |
| SKILL_FOUNDATION | **PASS** |
| PRODUCTION_RPG_UI | **PASS** |
| PERSISTENCE | **PASS** |
| M03_COMBAT_REGRESSION | **PASS** |
| MULTIPLAYER_REGRESSION | **PASS** |
| VISUAL_FOUNDATION_LOCKED | **TRUE** |
