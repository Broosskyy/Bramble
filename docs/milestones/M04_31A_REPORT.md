# BRAMBLE M04.31A — World Art & Composition Convergence

Date: 2026-09-18  
Engine: Godot 4.7.2  
Status: **PASS**  
Decision: **B — ONE TARGETED ART GAP REMAINS**

## Repository

- Start HEAD / origin/main: `b472ad289636f5cc2d74684ffe70dfee3ac7ce40`
- End implementation HEAD: `4af0f55a39f09f7f24d4544c0c2c46903d73bb5a`
- Branch: `main`
- Implementation commit: `feat(m04.31a): converge world art and composition`
- Push: pending delivery update

## Visual changes

- Replaced rectangular cobble strips with cataloged transparent road modules:
  vertical, horizontal, bend, cross, and cobble transitions.
- Reduced grass repetition scale and integrated planted path edges.
- Rebuilt composition as house, rest/social, route-landmark, forest-edge,
  and low-clutter combat pockets.
- Replaced the primitive Hall with the authored Kit45 autumn cottage,
  retaining a spatial footprint, collision, grounding, and obstruction fade.
- Replaced the primitive portal arch with the authored Kit41 milestone.
- Added restrained background tree/understory layers and a distinct workshop
  hint to create foreground/midground/background depth.
- Kept the accepted canonical Kit60/70/71 Moorling implementation unchanged.

## Results

- Building: authored facade/sides/roof/foundation remain coherent at center
  and both ±45° camera bounds.
- Ground/path: route remains immediate but no longer has hard rectangular
  yellow strips or 90-degree primitive joins.
- Player/equipment: visible idle progression remains clear; existing
  anticipation, weapon swing, impact VFX, recovery, depth, and attachment
  synchronization remain functional.
- Prototype geometry: removed from the Hall and waystone hero composition.
- UI: retained the compact functional HUD; no feature-level UI rewrite.

## Assets reused

`road_vertical`, `road_horizontal`, `road_bend`, `road_cross`, `road_cobble`,
Kit45 `cottage_complete`, `milestone`, `garden`, `flower_bed`, `town_gate`,
`workshop`, `apple_tree`, and `thornberry_bush`. All are existing cataloged
BRAMBLE assets; no generated or external proprietary content was added.

## Performance

- M04.30: 148 nodes, 130 draw calls, 31 materials, 43 transparent, 63 shadows.
- M04.31A: 101 nodes, 46 draw calls, 17 materials, 57 transparent, 3 shadows.
- Four animated entities and five collision shapes remain.
- Transparency increased for authored path/environment cards, while total
  nodes, draw calls, materials, and shadow casters fell materially.
- Desktop automated result only; no mobile claim.

## Tests

- Project parse: PASS
- M04.31A scene/smoke: PASS (`nodes=104`)
- Movement, camera follow/yaw/zoom, equipment, combat, loot/progression: PASS
- Center/left/right and landscape/portrait visual captures: PASS
- Hall/landmark grounding and obstruction behavior: PASS
- Moorling rendering / no Kit21 regression: PASS
- Asset catalog integrity: PASS with documented pre-existing review items
- Multiplayer: not rerun; shared presenter/network code was not changed
- Android: OUT OF SCOPE

## Screenshots

Fresh captures: `artifacts/m04_31a/01_...png` through
`artifacts/m04_31a/14_...png`, covering baseline, path, Hall at three yaw
angles, environment cluster, combat clearing, equipment idle/attack, final
center/left/right, landscape, and portrait.

Hero captures:

- `artifacts/m04_31a/13_final_gameplay_landscape.png`
- `artifacts/m04_31a/14_final_gameplay_portrait.png`

## Remaining visual gaps

- P0: none.
- P1: one authored player body + helmet/armor/weapon attack-pose set is still
  required to exceed the current procedural synchronization quality ceiling.

## M04.3 safety

All protected M04.3 tracked files, 29 captures, and untracked UID files remain
preserved and uncommitted. None were staged in the M04.31A implementation.
