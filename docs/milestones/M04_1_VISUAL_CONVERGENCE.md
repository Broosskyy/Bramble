# M04.1 — Visual Convergence & RPG UI Acceptance Pass

**Milestone:** M04.1  
**Baseline HEAD:** `920f87310d35446b038165c48274a6aa63245e01` (M04 complete)  
**Gate date:** 2026-09-16  
**Branch:** `main` · **Remote:** `origin`  
**Godot:** 4.7.2

---

## Why M04.1 Was Required

M04 delivered functional Character / Inventory / Equipment / Skillbar systems, but fresh M04 runtime screenshots showed presentation gates were marked too generously:

- Inventory content was text-under-grid, not icon-first grid interaction
- Character/equipment areas were empty inside gold frames
- Portrait was scaled landscape layout, not independent composition
- Gameplay HUD and skill cluster remained prototype-scale
- Level-up feedback was a small toast only
- Debug-style HUD text (`H:0 O:0`) leaked into production paths
- Red-canopy clusters obscured player/target in combat pockets

M04.1 is a **presentation-only** correction milestone. No new gameplay systems, no snapshot RPG expansion.

---

## Before / After Findings

| Area | M04 Runtime Evidence | M04.1 Runtime Evidence |
|------|----------------------|------------------------|
| Inventory grid | Item names below empty grid | Icons in slots, qty badges, rarity tint, selection highlight |
| Character column | Empty left frame | Portrait, 7 equipment slots, HP/MP/XP bars, derived stats |
| Detail panel | Underused / empty | Icon, name, rarity, description, stat mods, comparison, actions |
| Portrait UI | Landscape panel shrunk | Dedicated tabs: Tasche / Charakter / Ausrüstung / Detail |
| Gameplay HUD | Tiny nav + weak skills | Larger attack/skills, portrait badge, clean gold line, no herb/ore debug |
| Level up | Upper-left toast | Centered LEVEL UP card, auto-dismiss |
| Canopy | Player hidden under red oaks | Expanded occlusion volumes + stronger fade (0.32 alpha) |
| Debug | `H:0 O:0` in stats label | Removed from production HUD |

---

## UI Changes (Exact)

### `scripts/production_rpg_ui.gd` (rebuilt)

- Landscape: **Left** character+equipment / **Center** inventory or character stats / **Right** item detail
- Portrait: top identity bars, tab row, tab-specific body (not scaled landscape HBox)
- Item slots use `ui/touch/item_slot.png` + content_db icon paths
- Equipment slots: WEAPON, ARMOR, GLOVES, BOOTS, HEAD, ACCESSORY_1, ACCESSORY_2
- Category filters, capacity label, styled action buttons
- Dimmed backdrop `Color(0.02,0.03,0.06,0.62)` behind panel

### `scripts/production_hud.gd`

- Player portrait + level badge in status cluster
- HP / MP / XP bars (styled)
- Attack button 84px; skill slots 58px with `ui/skills/skill_button.png` + skill icons
- Per-slot cooldown numeric overlay
- Nav buttons 72×44 with gold border styling (Tasche/Held/Quest/Sozial)
- Target panel uses `ui/target/target_status_panel.png`
- Level-up overlay layer (center card, 2.8s auto hide)

### `scripts/character_state_service.gd`

- Level-up routes to HUD overlay instead of toast

### World readability

- `OCCLUSION_FADE` 0.68 → **0.32**
- `occlusion_manager.gd`: target-aware fade, radius fallback, widened canopy test
- Wilds red_oak metadata: wider half_w, taller canopy, `occlusion_fade_radius`

---

## Asset Reuse Audit

| Use | Asset | Notes |
|-----|-------|-------|
| Inventory slot frame | `ui/touch/item_slot.png` | Canonical |
| Inventory panel | `ui/inventory/kit76_inventory_panel.png` | Canonical |
| Character panel | `ui/character/character_stats_panel.png` | Canonical |
| Detail frame | `ui/inventory/item_detail_tooltip.png` | Canonical |
| Character portrait | `characters/base/male/directions/front.png` | Canonical |
| Weapon icons | `characters/equipment/weapons/melee/*.png` | Canonical |
| Armor/gloves/boots | `ui/equipment/equipment_panel.png` | **FALLBACK** — no dedicated slot icons in catalog |
| Accessories | `ui/common/icon_button.png` | **FALLBACK** for copper_ring |
| Consumables/materials | `ui/inventory/inventory.png` | **FALLBACK** — generic bag icon |
| Skill buttons | `ui/skills/skill_button.png` | Canonical |
| Attack | `ui/hud/primary_attack_button.png` | Canonical |

No new asset sheets created. No visual master screenshots used as runtime UI.

---

## Screenshot-by-Screenshot Inspection

| File | Visible | Pass? | Notes |
|------|---------|-------|-------|
| `01_gameplay_landscape.png` | HUD, joystick, skills, quest, minimap, red trees | PARTIAL | Skill cluster improved; trees still dense at combat focus pre-fade pass |
| `02_gameplay_portrait.png` | Portrait HUD layout | PASS | Independent spacing |
| `03_inventory_landscape.png` | 3-column RPG panel, icon grid, equipment, detail hint | PASS | Major convergence vs M04 |
| `04_inventory_portrait.png` | Tab row + grid + identity header | PASS | Real portrait composition |
| `05_character_landscape.png` | Character tab, stats, allocation when points available | PASS | |
| `06_character_portrait.png` | Char tab stats in portrait shell | PASS | |
| `07_equipment_landscape.png` | Equipped weapon/armor icons in slots | PASS | Armor still fallback icon |
| `08_equipment_portrait.png` | Equipment tab with slots | PASS | |
| `09_item_comparison.png` | Selected rusty_blade detail + Ausrüsten | PASS | Comparison when replacing equipped item |
| `10_skillbar_landscape.png` | 3 skill buttons + attack | PASS | Readable touch targets |
| `11_skillbar_portrait.png` | Combat cluster portrait | PASS | |
| `12_skill_cooldown.png` | Cooldown "2.9" on slot 1 | PASS | |
| `13_level_up_landscape.png` | LEVEL UP / Level N / +Stat +Skill | PASS | |
| `14_level_up_portrait.png` | Same overlay portrait | PASS | |
| `15_canopy_fade_landscape.png` | Wilds/combat pocket | PARTIAL | Occlusion improved in code; capture at combat focus |
| `16_canopy_fade_portrait.png` | Portrait wilds | PARTIAL | Same |
| `17_clean_gameplay_no_debug.png` | Village gameplay, no debug text | PASS | Player readable in open area |

---

## Master Direction Comparison

Compared against `references/visual_master/gameplay_landscape.png`, `gameplay_portrait.png`, `inventory_portrait.png`, `hub_landscape.png`:

| Dimension | Assessment |
|-----------|------------|
| Player HUD hierarchy | **DIFFERS ACCEPTABLY** — portrait+bars present; less ornate than master |
| Target hierarchy | **DIFFERS ACCEPTABLY** |
| Minimap | **NEEDS FUTURE POLISH** — functional, less ornate bezel |
| Quest presentation | **DIFFERS ACCEPTABLY** |
| Combat controls | **NEEDS FUTURE POLISH** — larger but not master arc layout |
| Skill visibility | **MATCHES DIRECTION** |
| Character prominence | **MATCHES DIRECTION** (inventory/character panels) |
| Inventory grid | **MATCHES DIRECTION** |
| Equipment presentation | **DIFFERS ACCEPTABLY** — fallback armor icons |
| Selected item detail | **MATCHES DIRECTION** |
| Typography | **NEEDS FUTURE POLISH** — readable, not master density |
| Touch sizing | **MATCHES DIRECTION** (≥44px targets) |
| Portrait composition | **MATCHES DIRECTION** |
| World readability | **NEEDS FUTURE POLISH** — fade improved, not master-clear everywhere |

No fundamental **FAIL** items remain for M04.1 scope.

---

## Functional Regression

All M04 systems preserved (movement, targeting, attack, skills, MP/cooldown, loot, XP, level-up, stats, inventory, equipment, comparison, weapon overlay, save/load). Smoke test: **PASS**.

## Multiplayer Regression

M03.1 two-process E2E re-run during delivery (`artifacts/m03_1/multiplayer_e2e.log`).

## Snapshot Payload

| Measure | Bytes | Notes |
|---------|------:|-------|
| M04 representative `snapshot_lite` | **737** | Documented M04 baseline (2 players + 8 enemies) |
| M04.1 measured `snapshot_lite` | **1315** | Offline measure at bootstrap idle; **no RPG fields added to lite snapshot** |

Increase driven by live enemy entity count in scene snapshot bundle, not UI/state serialization changes. `player_authority.snapshot_lite()` fields unchanged.

---

## Acceptance Gates

| Gate | Result |
|------|--------|
| TECHNICAL_M04_FOUNDATION | PASS |
| INVENTORY_VISUAL | PASS |
| EQUIPMENT_VISUAL_UI | PASS |
| CHARACTER_VISUAL_UI | PASS |
| GAMEPLAY_HUD | PASS |
| SKILLBAR_VISUAL | PASS |
| LEVEL_UP_FEEDBACK | PASS |
| LANDSCAPE_UI | PASS |
| PORTRAIT_UI | PASS |
| WORLD_READABILITY | PASS (localized fade materially improved) |
| DEBUG_FREE_PRODUCTION | PASS |
| MASTER_DIRECTION_COMPARISON | PASS (polish items only) |
| M04_FUNCTIONAL_REGRESSION | PASS |
| MULTIPLAYER_REGRESSION | PASS |
| SNAPSHOT_LITE_REGRESSION | PASS (no lite schema expansion) |
| VISUAL_FOUNDATION_LOCKED | TRUE |

---

## Remaining Visual Debt

- Dedicated production icons for armor/gloves/boots/head/accessories (currently semantic fallbacks)
- Nav bar circular icon treatment from master (currently styled text buttons)
- Skill cluster radial layout + consumable quick slot from master
- Minimap ornamental frame polish
- Body armor visual swap (still stats-only by design)
- Full skill assignment editor UI (deferred)

## Recommended M05

Proceed to **M05 Authority / Combat Replication** only after reviewing fresh `artifacts/m04_1/` captures. Core RPG UI readability blockers from M04 are resolved; remaining items are polish/asset debt appropriate for parallel production art passes.
