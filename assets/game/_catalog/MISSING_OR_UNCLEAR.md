# Missing or Unclear

Total source records originally flagged: 0

## REVIEW_REQUIRED — pre-existing canonical collisions

The integrity recovery validator found 12 canonical paths that represent
different hashes. The old collision resolver preserved only one physical file
for each path. The resolver is fixed for future rebuilds, but the absent
variants cannot be recovered truthfully without the original source archives:

- Ember Knight kit 48: male/female `front`, `back`, and `right` collide (3 paths)
- Village merchants kit 46: male/female `front`, `back`, and `right` collide (3 paths)
- Root Guardian kit 47: action and direction masters collide (1 path)
- Archive metadata: alpha report, manifest, QA report, style lock, and preview collide (5 paths)

Do not infer or mirror the absent gender/direction variants. Re-run
`tools/asset_foundation_01.py` only after the original `_asset_import` archives
are available; its corrected resolver will emit unique source-identity paths.

## REVIEW_REQUIRED — remaining composite masters

Composite `master.png` files generated before this recovery may still reside
under runtime semantic folders. No runtime code references those masters. The
builder now routes every future master to `references/source_sheets/`, but the
remaining historical files require source-by-source visual verification before
they are moved.

## REVIEW_REQUIRED — merchant identity split

Runtime uses `npcs/merchant/` (kit 59), while unreferenced kit 46 assets were
generated under `npcs/merchants/`. The kit 46 male/female collision losses must
be recovered before those trees can be merged without discarding an identity.

## Visual Master References

Updated: 2026-09-15T19:25:13.553446+00:00

The following files are **intentionally not production assets**:

- `references/visual_master/gameplay_landscape.png`
- `references/visual_master/gameplay_portrait.png`
- `references/visual_master/inventory_portrait.png`
- `references/visual_master/hub_landscape.png`

Status: **VISUAL_MASTER_REFERENCE_ONLY** — do not import into `assets/game/`.
