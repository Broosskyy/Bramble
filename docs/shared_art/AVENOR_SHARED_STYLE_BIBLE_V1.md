# AVENOR — Shared Game Art Bible v1.0
Status: **PROPOSED SHARED PRODUCTION CONTRACT** — approval is per asset and per game.  
Source-of-truth art library: `Broosskyy/Bramble`.  
Consumers: **BRAMBLE** (oblique 2.5D online action RPG) and **REALM ALLIANCE** (portrait-first, fixed-arena idle/tap RPG).  
Created 2026-10-10. This branch is documentation-only; **no existing assets have been moved or replaced**.

## 1 — Shared style, separate intellectual properties
- Adopt the **existing BRAMBLE anime/chibi fantasy production art direction**, not a generic new art style. Establish fidelity through the actual image masters and approved runtime captures, not color guesses, file names or automatic art-style transfer.
- Preserve consistent: face/anatomy proportions, silhouette weight, edge treatment, material highlights, light direction, render sharpness, alpha handling, world footpoints, and clear readable equipment.
- Shared production language **does not imply** shared universe, lore, character identity, game UI, monetization, progression or animation timing.
- **BRAMBLE identity** remains Hainweiler/Nebelbruch, its location/character/NPC hierarchy, oblique traversable world and specialist identity.
- **REALM ALLIANCE identity** remains Realmwächter, portrait fixed-arena composition, tap/auto skill feedback, enemy pressure, hero evolution/equipment and the approved five master screens.
- General-purpose environment tiles, foliage, rocks, containers, generic combat particles and generic weapon bases MAY be dual-use after provenance and camera/scale validation. Signature characters, bosses, faction symbols, named items and branded UI default to **project-only**.
- Asset categories and design style may be shared even when textures themselves are not.

## 2 — Existing BRAMBLE production contracts are authoritative
Reuse these specifications instead of reinventing them:
- `docs/production/BRAMBLE_ASSET_SCALE_BIBLE.md`
- `docs/production/BRAMBLE_POSE_SOCKET_BIBLE.md`
- `docs/art/BRAMBLE_ANIMATION_PRODUCTION_STANDARD.md`
- `docs/art/BRAMBLE_ROTATION_READY_ASSET_STANDARD.md`
- `docs/production/BRAMBLE_ASSET_CREATION_QUEUE.md`
- `assets/game/_catalog/ASSET_MANIFEST.csv` and provenance mappings

Production master standards already documented by BRAMBLE:
- Standard humanoid master: **512×512 RGBA, straight alpha**, ground pivot **(256, 464)**, stable identical canvas across related directions, layers and states.
- Locked special exception: *Wayfarer M04.31B* melee family has **(256, 468)**. Do not quietly normalize it.
- Keep **24 px minimum transparent safe margin** for individual character frames. For generated multi-asset review sheets use **at least 32 px gutters and 32 px outer margin**. No overlapping silhouettes/shadows, no labels, no presentation backgrounds.
- Do not mix source-sheet crops and runtime-ready singles without catalog extraction/provenance; `SOURCE_SHEET`, `EXTRACTED_ASSET`, `DERIVED_ASSET`, `RUNTIME_ASSET`, `REFERENCE`, `EXPERIMENTAL` remain distinct.
- Preserve hashes, original ZIPs, image source, rights notes, crop/trim offsets, pivots and Godot import settings. No opaque baked background, clipped sword tips or colored alpha fringes.

## 3 — Perspective matters
**BRAMBLE:** world camera normally oblique orthographic ~38°, characters can turn; master source assets may have up to eight authored directions. Player/camera/world transforms follow BRAMBLE-specific world/collision/pivot rules.

**REALM ALLIANCE:** fixed portrait battle arena, where player and enemy must face their target. Pick and verify the **actual appropriate directional view** for each asset, then author matching windup/commit/hit/defeated states at that same view. Do not arbitrarily rotate a frontal PNG or attach a sword to a painted closed fist and call it modular.

The same source identity can have two separate **runtime presentation adapters**, with the original art never overwritten:
- `shared/source/<asset-id>/...` as tracked source reference (not automatically copied)
- `bramble/runtime/<asset-id>/...` directional world sprites / spatial parts
- `realm/runtime/<asset-id>/...` fixed-battle keyposes / attachments

## 4 — Animation and attachment acceptance
- Shared vocabulary: idle, ready, windup, contact, followthrough, recovery, hit, defeated; movement states are added when needed by gameplay.
- For humanoids, explicit `ground`, `head`, `hand_l`, `hand_r`, `weapon_main`, `weapon_tip`, `back`, `hit`, `shadow`, `loot`. For monsters add anatomy sockets only when present.
- Armor/helm/hair/wings/weapon are independent layers when equipment changes are a game feature. Matching parts share identical pose/frame/canvas unless a validated trim map exists. A weapon must occupy the correct grip position for **windup, contact and recovery**, not just idle.
- Authored body/weapon attack keyposes are needed when anatomy changes. Godot tweens may enhance animation but cannot turn a single idle still into a credible attack.
- Preserve stable feet/ground pivot; no accidental body jumps, boss size resets, mirrored asymmetric handedness or per-animation scale compensation.

## 5 — Two product policies
| Family | BRAMBLE | REALM ALLIANCE |
|---|---|---|
| Generic terrain / foliage / crates / rocks | Primary source | Candidate direct reuse as correctly composed stage layers |
| Generic VFX glints / slash / impacts | Primary source | Candidate reuse with timing/scale adaptation |
| Generic weapon silhouettes | Shared candidate | Separate actual weapon sprite, correct handle pivot/socket |
| Humanoid base anatomy | Reference/candidate | Shared style; project-specific Realmwächter clothes/face/evolution |
| Signature monster / boss | Original identity | Distinct silhouettes, poses and names by default |
| World landmark / faction visuals | Exclusive | Do not copy as REALM identity |
| UI | BRAMBLE navigation/world HUD | REALM five-screen master & portrait combat HUD |

## 6 — Verification gate for each promoted asset
Record `asset_id`, origin project, verified source path, original SHA-256, commercial license/provenance, semantic type, direction/state, source canvas/alpha, logical bounds, pivot and socket map, dual-use classification, runtime target path, and visual capture references.

The acceptance order is **image inspection → identity/provenance audit → alpha/trim/socket QA → Godot import → Web portrait capture → real Android portrait capture → project-specific gameplay acceptance**. Catalog listing alone is not acceptance.

Critical BRAMBLE facts: legacy documentation lists **391 unique PNG/WebP images** in the deduplicated discovery pool, *not* 391 approved, complete, retargetable production sprites. Monster attack/walk coverage remains partial in the September animation matrix. `moorling` identity comes from Kit60/70/71; Kit21 is vegetation. Do not assign missing directions/poses based on suggestive filenames.

## 7 — Non-destructive implementation rule
No bulk copy, repo merge, ZIP reimport, renaming or texture overwrite merely because an asset appears usable. First build a machine-readable cross-game candidate manifest pointing to exact BRAMBLE source paths and classify entries `CANDIDATE` or `APPROVED`. A REALM importer may copy **only approved, hashed singles** to an isolated destination after successful runtime validation. Preserve independent Godot project settings, save compatibility and existing `main` branches.

## 8 — Next proof
**REALM ALLIANCE Production Batch 01** consumes these rules to validate one shared sword, one shared slash sequence, an appropriate front-facing base-character reference and one small environment stack, then produces the project-specific Realmwächter and target monster(s). The target is a visibly better combat screen, not a mass-produced set of untested PNGs.
