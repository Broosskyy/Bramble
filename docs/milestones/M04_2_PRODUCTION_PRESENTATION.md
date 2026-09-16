# M04.2 — Production Presentation Convergence

Milestone: M04.2  
Baseline: `5b61ea0ceffafc0b21e476ea9fd5f8c94037cf36`  
Date: 2026-09-16  
Godot: 4.7.2  
Visual foundation lock: TRUE

## Initial Repository Audit

- KEEP: world/camera/elevation foundations, mobile controls, live minimap architecture, CharacterState boundary, combat runtime, content database, orientation service, multiplayer minimum and `snapshot_lite`.
- POLISH: player HUD, quest tracker, target card, minimap frame/markers, level-up card and safe-area spacing.
- RECOMPOSE: inventory, character, equipment, portrait RPG flow, bottom navigation and combat-control hierarchy.
- FIX: late HUD service binding, instance-aware equipment transaction ordering, portrait logical canvas, player footpoint sorting, contextual canopy coverage and deterministic M04.2 evidence.
- DEPRECATE: generic item/skill icon assignments and one-off UI style boxes.
- MISSING ASSET: dedicated player/enemy portraits, coherent navigation family, isolated armor/accessory icon family, complete skill icon family and level-up VFX package.

## Visual Audit and Master Analysis

The four Masters establish compact framed HUD islands, clear world center, prominent attack/ability hierarchy, icon-led navigation, a character-first RPG presentation and task-focused portrait flows. M04.1 had sound functional foundations but still presented tiny web-like navigation, generic item art, underused framed space, weak equipment hierarchy and incomplete canopy proof.

Largest perceptual gaps:

1. World art quality materially exceeded HUD/RPG UI quality.
2. Character, bag and detail regions lacked a clear reading order.
3. Portrait behaved as a reduced layout instead of a task flow.
4. Attack, skills and navigation lacked icon/scale hierarchy.
5. Equipment slots did not reliably display authoritative equipped state.
6. Dense red canopies could hide both player and target.
7. Runtime services created after HUD initialization were not bound, causing target/cooldown feedback to remain stale.

## Implementation Decisions

- Added `BrambleUiStyle` as a focused shared language for panel, inset, button, label, progress, color and 48px touch sizing.
- Rebuilt the RPG shell as landscape cards and portrait task tabs without changing authoritative RPG state ownership.
- Kept all runtime composition in Godot and reused semantic canonical assets.
- Fixed equipment instance handling instead of staging fake equipped visuals.
- Preserved map/camera/world foundations; only local sorting and occlusion behavior changed.

## Presentation Changes

### HUD, Navigation, Skills and Minimap

- Player portrait now renders predictably with name/level and HP/MP/XP hierarchy.
- Target UI is compact and contextual; late-created targeting/combat services bind safely.
- Primary attack is dominant; three radial skill positions retain locked/cooldown states and semantic icons.
- Navigation uses larger fantasy-styled controls and available semantic icons.
- Minimap has stronger frame/background contrast while retaining the live SubViewport implementation.
- Landscape and portrait positions use logical 1280×720 and 720×1280 canvases with safe margins.

### Inventory

- Landscape: character summary left, useful bag grid center, contextual details/actions right.
- Portrait: dedicated Bag task with identity strip, filter row and five-column touch grid.
- Items show semantic icon, quantity, rarity/selection and capacity.

### Character and Equipment

- Character screen prioritizes avatar, progression, primary allocation and derived combat information.
- Equipment screen presents a restrained paper doll, seven understandable slots, equipped list and comparison.
- Equipped weapon/armor now visibly occupy their slots in both orientations.
- Equipment transaction order and instance-specific inventory consumption were corrected.

### Portrait Strategy

Portrait uses four primary tasks: `TASCHE`, `HELD`, `GEAR`, `DETAIL`. Only the active task owns the main viewport. Scroll is used for secondary content; primary buttons remain at least 44px effective size.

### Canopy and Readability

- Player footpoint sorting was attached to the world player.
- Occlusion now accepts radius coverage as a first-class condition instead of requiring a narrow horizontal intersection.
- Fade alpha is 0.16 and only relevant occluders transition.
- Disabling occlusion restores all affected sprites immediately.
- Evidence 21→22 shows the obstructing foreground red canopy clearing while surrounding trees remain lush; 23 shows the readable player and active combat target.

### Level-Up

The centered, temporary and non-blocking M04.1 concept is retained. Capture timing is deterministic in both orientations and shows level plus stat/skill rewards.

## Responsive and Safe-Area Review

- Logical portrait and landscape canvas sizes are applied by the orientation service.
- Joystick, attack cluster, minimap, HUD and navigation remain inside margins in all evidence.
- Portrait RPG content reflows rather than scaling landscape.
- No essential control is clipped; scroll is intentional on the long portrait equipment list.

## Runtime and Functional Regression

- Godot project parse/start: PASS.
- Production smoke test: PASS.
- M04.2 capture validates live targeting, skill execution, cooldown path, loot insertion, instance-aware weapon/armor equip, comparison, XP/level-up and orientation changes; capture exits non-zero on skill/equipment staging failure.
- Movement/camera, inventory selection, stat recalculation, quest tracker and portal/world foundations remain on established services and are visible or preserved.
- M03.1 real two-process E2E: PASS on port 27971, including join, mutual visibility, bidirectional movement, disconnect cleanup, reconnect and duplicate-avatar guard.
- Snapshot lite: 1315 bytes. No RPG/UI field was added to the frequent schema; this matches the M04.1 representative measurement.

## Screenshot Evidence Matrix

Format: expected; actually visible; readability; clipping; overlap; asset quality; touch quality; Master difference; result.

1. `01_gameplay_landscape.png` — exploration HUD; village, HUD, minimap, navigation and controls; clear; none; intentional islands; production world/semantic UI; 48px+; less ornate; PASS.
2. `02_gameplay_portrait.png` — portrait exploration; genuine tall composition and controls; clear; none; none harmful; coherent; 48px+; fewer contextual systems; PASS.
3. `03_clean_hud_landscape.png` — uncluttered HUD; compact corners and open center; clear; none; none; coherent; good; simpler than Master; PASS.
4. `04_clean_hud_portrait.png` — uncluttered portrait HUD; first-class reflow; clear; none; none; coherent; good; simpler than Master; PASS.
5. `05_combat_landscape.png` — selected enemy and controls; target HP/range, ring and skill cluster; clear; none; foliage remains dense; good; good; less VFX-rich; PASS.
6. `06_combat_portrait.png` — portrait combat; contextual target and safe controls; clear; none; none harmful; good; good; more world-first than Master; PASS.
7. `07_target_panel.png` — target card; Moorling name, HP and range; clear; none; none; coherent; noninteractive; no enemy portrait; PASS.
8. `08_skillbar_landscape.png` — attack plus three abilities; radial cluster and locked slot; clear; none; none; semantic first two icons; good; less ornate; PASS.
9. `09_skillbar_portrait.png` — portrait combat cluster; safe bottom-right grouping; clear; none; none; coherent; good; compact; PASS.
10. `10_skill_cooldown.png` — live skill cooldown; runtime cooldown state on active slot; readable at runtime; none; none; canonical cooldown treatment; good; less dramatic; PASS.
11. `11_inventory_landscape.png` — three-region bag; character, populated grid and context; strong; none; none; semantic items; good; denser Master remains; PASS.
12. `12_inventory_portrait.png` — phone bag task; identity, filters and five-column grid; strong; none; none; semantic items; good; fewer secondary panels by design; PASS.
13. `13_inventory_item_selected.png` — selected detail/action; item, rarity, stats and equip action; strong; none; none; semantic; good; simpler tooltip ornament; PASS.
14. `14_character_landscape.png` — avatar/stats/progression; clear three-card hierarchy; strong; none; none; coherent; allocation buttons usable; less decorative; PASS.
15. `15_character_portrait.png` — portrait character task; avatar then primary/derived stats; strong; intentional scroll boundary; none; coherent; good; progressive disclosure; PASS.
16. `16_equipment_landscape.png` — equipped paper doll; weapon/armor slots, list and comparison; strong; none; none; semantic equipped icons; good; simplified paper doll; PASS.
17. `17_equipment_portrait.png` — portrait gear task; character, occupied slots and list; strong; intentional scroll; controlled slot overlay; coherent; good; less ornate; PASS.
18. `18_equipment_comparison.png` — replacement comparison; negative deltas against forest blade; strong; none; none; semantic weapon; good; intentionally focused detail task; PASS.
19. `19_level_up_landscape.png` — runtime level-up; centered level/rewards over world; strong; none; no harmful overlap; coherent; noninteractive; less VFX; PASS.
20. `20_level_up_portrait.png` — portrait level-up; compact centered card; strong; none; no harmful overlap; coherent; noninteractive; less VFX; PASS.
21. `21_canopy_before_fade.png` — obstruction baseline; player hidden by relevant red canopy; intentional baseline; none; expected overlap; production world; n/a; denser than Master gameplay pocket; PASS.
22. `22_canopy_active_fade.png` — contextual clearing; player body becomes readable while adjacent trees remain; strong; none; relevant fade only; production world; n/a; matches readability principle; PASS.
23. `23_canopy_combat_readability.png` — target under canopy; player and selection ring readable; strong; none; controlled foliage; production world; controls safe; matches direction; PASS.
24. `24_navigation_landscape.png` — bottom navigation; four compact icon-led actions; clear; none; none; semantic/fallback mix; good; needs dedicated icon family; PASS.
25. `25_navigation_portrait.png` — portrait navigation; centered safe row; clear; none; none; coherent; good; needs dedicated icon family; PASS.
26. `26_minimap.png` — live minimap; frame, player and markers visible; clear; none; none; production frame; n/a; richer marker family missing; PASS.
27. `27_final_gameplay_landscape.png` — final clean exploration; open center and complete gameplay HUD; strong; none; none harmful; coherent; good; less ornate; PASS.
28. `28_final_gameplay_portrait.png` — final clean portrait; world-first composition and safe controls; strong; none; none harmful; coherent; good; less system-dense by design; PASS.

## Final Master Comparison

- MATCHES_DIRECTION: gameplay hierarchy, inventory grid, item detail, character prominence, level-up, responsive portrait task flow, touch usability and canopy readability.
- DIFFERS_ACCEPTABLY: quest density, world-first portrait composition, compact target treatment and simplified paper doll.
- NEEDS_FUTURE_POLISH: dedicated navigation iconography, minimap marker family, richer typography/ornament, dedicated skill icons and celebratory level-up VFX.
- MISSING_PRODUCTION_ASSET: player/enemy portraits, Social icon, isolated accessory/head/glove icon set and full skill icon family.
- FAIL: none.

Overall `MASTER_DIRECTION_COMPARISON` is PARTIAL: the runtime materially follows the Masters' hierarchy and usability, but deliberately does not claim asset-level parity where production art is missing.

## Acceptance Gates

- REPOSITORY_AUDIT = PASS
- ASSET_AUDIT = PASS
- MASTER_ANALYSIS = PASS
- GAMEPLAY_PRESENTATION = PASS
- PLAYER_HUD = PASS
- TARGET_UI = PASS
- MINIMAP_UI = PASS
- NAVIGATION_UI = PASS
- COMBAT_CONTROL_UI = PASS
- SKILLBAR_VISUAL = PASS
- INVENTORY_PRESENTATION = PASS
- CHARACTER_PRESENTATION = PASS
- EQUIPMENT_PRESENTATION = PASS
- ITEM_COMPARISON_PRESENTATION = PASS
- LEVEL_UP_FEEDBACK = PASS
- LANDSCAPE_UI = PASS
- PORTRAIT_UI = PASS
- TOUCH_USABILITY = PASS
- SAFE_AREA = PASS
- WORLD_READABILITY = PASS
- CANOPY_OCCLUSION = PASS
- DEBUG_FREE_PRODUCTION = PASS
- ASSET_COHERENCE = PASS
- MASTER_DIRECTION_COMPARISON = PARTIAL
- M04_FUNCTIONAL_REGRESSION = PASS
- MULTIPLAYER_REGRESSION = PASS
- SNAPSHOT_LITE_REGRESSION = PASS
- VISUAL_FOUNDATION_LOCKED = TRUE

## Remaining Visual Debt and Missing Assets

- Dedicated portrait art, navigation family, equipment/accessory icon family and full skill icon set.
- Minimap markers and bezel can move closer to Master finish.
- Typography remains system-font based.
- Target card would benefit from enemy portraits and hit-state animation.
- Quest tracker can gain a true collapse control in a later presentation pass.

## M05 Readiness

M04.2 introduces no full authority/combat replication work and no snapshot schema expansion. Presentation and the M04 adapter are ready for M05 authority/combat replication, while the documented asset debt can proceed independently.
