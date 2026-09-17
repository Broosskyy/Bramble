# BRAMBLE Asset Catalog Integrity Audit

Date: 2026-09-17
Scope: asset identity, provenance, runtime readiness, and catalog integrity
Status: corrected high-confidence errors; unresolved source-loss cases are flagged

## Root cause

The original catalog builder trusted kit folders and filenames as semantic
identity. That assumption is false. Several supplied records contain exact
copies of unrelated source sheets, and a composite source sheet may contain
multiple independently usable assets.

Two pipeline defects amplified the source errors:

1. `master.png` files were sometimes routed into runtime entity folders.
2. Different hashes that collided at one canonical path were renamed using
   only the kit number, so same-kit variants still collided and one physical
   file was lost.

The repaired rule is:

> Source sheets are provenance. Extracted, semantically verified assets are
> runtime identity. Folder and filename hints never override visual/hash
> evidence.

Reviewed exceptions now live in
`assets/game/_catalog/SEMANTIC_OVERRIDES.json`. The builder loads these
exceptions before applying naming heuristics, routes composite masters to
`references/source_sheets/`, normalizes POSIX manifest paths, and produces
unique collision paths from source identity.

## Kit 21 correction

SHA-256 proves
`BRAMBLE_21_29/21_moorling_directions/master.png` is byte-identical to
`BRAMBLE_KITS_11_20/11_nebelbruch_vegetation/sheet.png`
(`ba9b32728ec526a0637b32134a01e25b6909f2b90c0e304396f29ede619495c1`).
Visual inspection confirms four world assets, not a creature:

| Former false path | Canonical path | Identity | Classification |
|---|---|---|---|
| `monsters/moorling/directions/kit21_front.png` | `world/vegetation/swamp_willow.png` | `swamp_willow` | `WORLD_ASSET` / `UNRELATED` |
| `monsters/moorling/directions/kit21_right.png` | `world/vegetation/marsh_reeds.png` | `marsh_reeds` (cattails/fireflies) | `WORLD_ASSET` / `UNRELATED` |
| `monsters/moorling/directions/kit21_back.png` | `world/vegetation/glow_stump.png` | `glow_stump` (moss/mushrooms) | `WORLD_ASSET` / `UNRELATED` |
| `monsters/moorling/directions/kit21_left.png` | `world/vegetation/thornberry_bush.png` | `thornberry_bush` | `WORLD_ASSET` / `UNRELATED` |

The redundant false `monsters/moorling/kit21_master.png` copy was removed.
Its provenance now resolves to the existing canonical
`references/source_sheets/kit_11_nebelbruch_vegetation.png`; no duplicate
sheet was created. Kit 21 metadata is retained as provenance but its Moorling
label is not authoritative.

No runtime code referenced kit 21. Catalog and readiness references were the
only references requiring correction.

## True Moorling provenance

Visual inspection against the confirmed turquoise/green frog-like creature
establishes:

- Kit 60 master: `RELATED_SOURCE_SHEET`, canonical provenance at
  `references/source_sheets/kit_60_moorling_directions_actions.png`
- Kit 60 cardinal directions and actions: `CONFIRMED_MOORLING`
- Kit 70 idle/attack master: `RELATED_SOURCE_SHEET`
- Kit 70 individual idle/attack frames: `DERIVED_MOORLING`
- Kit 71 hit/defeated master: `RELATED_SOURCE_SHEET`
- Kit 71 individual hit/defeated frames: `DERIVED_MOORLING`

Kit 60 is the canonical identity source. Kits 70 and 71 are consistent
animation continuations of the same creature. Composite masters are
reference-only; extracted directions, actions, and frames are runtime-ready.

## Authoritative Moorling contract

| Contract entry | Status | Evidence |
|---|---|---|
| `MOORLING_CANONICAL_SOURCE` | EXISTS | kit 60 directions/actions; kits 70/71 animation provenance |
| `MOORLING_IDLE` | EXISTS | kit 60 idle action plus four kit 70 idle frames |
| `MOORLING_FRONT` | EXISTS | `directions/kit60_front.png` |
| `MOORLING_FRONT_RIGHT` | MISSING | no verified asset |
| `MOORLING_RIGHT` | EXISTS | `directions/kit60_right.png` |
| `MOORLING_BACK_RIGHT` | MISSING | no verified asset |
| `MOORLING_BACK` | EXISTS | `directions/kit60_back.png` |
| `MOORLING_BACK_LEFT` | MISSING | no verified asset |
| `MOORLING_LEFT` | EXISTS | `directions/kit60_left.png` |
| `MOORLING_FRONT_LEFT` | MISSING | no verified asset |
| `MOORLING_MOVEMENT` | MISSING | no walk/run frames in any direction |
| `MOORLING_ATTACK` | EXISTS | generic kit 60 action plus four kit 70 frames |
| `MOORLING_HIT` | EXISTS | generic kit 60 action plus four kit 71 frames |
| `MOORLING_DEFEATED` | EXISTS | generic kit 60 action plus four kit 71 frames |

The four action clips are not direction-bound. They must not be counted as
diagonal or per-direction action coverage.

## Exact Moorling art still required

1. Four independently authored diagonal idle/directional sprites:
   front-right, back-right, back-left, and front-left.
2. Authored movement animation. For full rotation-ready coverage this means
   walk/run coverage for all eight directions.
3. If combat must remain directionally correct while the camera rotates:
   direction-bound attack, hit, and defeated frames. Existing generic clips
   remain valid but do not provide directional coverage.

No graphics were generated, mirrored, or inferred during this recovery.

## Wider exact-duplicate audit

All eight exact duplicate groups in `DUPLICATES.md` were visually and
hash-audited. Each `BRAMBLE_21_29.zip` alias below had a false identity:

| False source label | Confirmed identity |
|---|---|
| `21_moorling_directions/master.png` | kit 11 Nebelbruch vegetation |
| `inventory_portrait_concept.png` | kit 12 Nebelbruch landmarks |
| `25_hud_frames/master.png` | kit 13 Alte Ruinen |
| `26_menu_frames/master.png` | kit 14 Kupfermine |
| `27_touch_controls/master.png` | kit 15 Kristallhöhle |
| `mooring_action_poses_master.png` | kit 16 world transitions |
| `28_raid_loot_ui/master.png` | kit 17 loot chests |
| `29_world_system_ui/master.png` | kit 18 region monsters |

The seven redundant, falsely named canonical copies outside kit 21 were
removed. Their source records remain in both manifest and source mapping as
`duplicate_of_primary` aliases of the correct kit 12–18 source sheets.
Individually extracted UI files from kits 25–29 were not reclassified merely
because their bundled `master.png` was wrong; they remain separate assets
pending independent evidence.

## REVIEW_REQUIRED / UNKNOWN

The current generated catalog has 12 pre-existing paths containing different
hashes. The old resolver retained only one physical file per path:

- Ember Knight kit 48 male/female front, back, and right: 3 collisions
- Village merchant kit 46 male/female front, back, and right: 3 collisions
- Root Guardian kit 47 action/direction masters: 1 collision
- Archive-level manifest/report/style/preview metadata: 5 collisions

The original `_asset_import` archives are not present in this worktree, so the
missing variants cannot be recovered or classified with integrity. They remain
`REVIEW_REQUIRED`; re-running the repaired builder with the original archives
is the required recovery path.

Remaining historical composite masters outside the audited set are also
`REVIEW_REQUIRED`. Runtime search found no code loading source masters, but
visual identity must be checked before moving each historical file.

The broader pre-correction scan counted 32 manifest master records (31
physical files) outside reference storage; 27 historical physical masters
remain after the confirmed Moorling/duplicate corrections. It also found a
`npcs/merchant/` versus `npcs/merchants/` identity split. Runtime uses singular
`merchant`; kit 46 plural merchant variants are unreferenced and affected by
the collision loss above. They are not merged until the absent male/female
files can be recovered.

## Catalog and runtime changes

- Reclassified 40 manifest records with evidence-backed runtime/source types.
- Corrected 16 source-path overrides and their provenance mappings.
- Moved three Moorling masters to reference-only source-sheet storage.
- Moved four kit 21 children to canonical world vegetation paths.
- Removed eight redundant false-identity source-sheet copies.
- Corrected Moorling matrix diagonal claims and generic clip coverage.
- Corrected the readiness candidate from kit 21 to kit 60.
- Added `tools/validate_asset_catalog.py`.
- Runtime references changed: none. Runtime already used kit 60 directions and
  kit 70/71 frames; no source master was loaded.

## Prevention rules

1. Never infer semantic identity solely from directory or kit filename.
2. Hash-match every master against the source-sheet catalog.
3. Store composite masters only under `references/source_sheets/`.
4. Store extracted assets by what they depict, not by source cell position.
5. Preserve every source path and hash in provenance mappings.
6. Never let different hashes share a canonical path.
7. Mark non-runtime sources `SOURCE_SHEET` or `REFERENCE_ONLY`.
8. Count generic clips only as generic clips, never directional coverage.
9. Use `UNKNOWN` / `REVIEW_REQUIRED` when visual evidence is unavailable.
10. Run `py -3 tools/validate_asset_catalog.py` after catalog changes.

## Validation record

Results:

- Repository-wide kit21/60/70/71/Moorling search: PASS; remaining old labels
  occur only as provenance, prevention checks, or audit documentation
- `py -3 tools/validate_asset_catalog.py`: PASS (16 reviewed overrides,
  24 Moorling runtime assets); 12 pre-existing collisions reported as
  `REVIEW_REQUIRED`
- Python syntax validation for catalog tooling: PASS
- Godot 4.7.2 headless editor parse/import: PASS
- Main runtime smoke: PASS
- M04.26 production-slice smoke: PASS (`nodes=261`)

M04.26 remains PARTIAL. This audit corrects asset truth only and does not claim
that any unmet visual acceptance gate has been satisfied.
