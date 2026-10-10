# BRAMBLE — Identity and Asset Sharing Policy

This document accompanies `AVENOR_SHARED_STYLE_BIBLE_V1.md`. It does **not** change BRAMBLE gameplay, art, assets, imports or `main`.

## BRAMBLE remains its own game
- World: its existing Hainweiler / Nebelbruch locations, locations/quests, oblique 2.5D traversable terrain, characters, specialists, pets and monsters.
- Camera and animation contract: its own `WORLD_CAMERA_SPEC`, 8-direction player and key hero content, direction-specific equipment overlays, 512×512 canvases with documented pivot exceptions.
- Monster identities such as `moorling`, `rootling`, `root_guardian`, `crystal_beetle` and `ruins_wisp` are **BRAMBLE-owned signature content by default**. Their existence in the source tree does not authorize creating identical REALM ALLIANCE iconic enemies.
- World landmarks, characters, specialist visuals, dialogue, faction logos, narrative and UI are project-specific.

## Shared production inventory — candidate, not automatically shipped
Existing examples to classify, deduplicate and visually inspect:

| Class | Verified BRAMBLE source directory | Sharing decision |
|---|---|---|
| Neutral weapons | `assets/equipment/weapons/` | Candidate for shared base; confirm grip geometry |
| Neutral armor parts | `assets/equipment/armor/` | Style/tech reference; project-specific visual appearance unless deliberately promoted |
| Generic sword effects | `assets/game/combat/vfx/melee_slash_sequence/frames/` | High-priority VFX candidate |
| Generic magic effects | `assets/game/combat/vfx/magic_support/frames/` | Candidate for neutral, non-signature spells |
| Seamless ground | `assets/game/world/terrain/seamless/` | Candidate shared terrain textures |
| Vegetation | `assets/game/world/vegetation/` | Candidate with camera and extraction checks |
| Generic props | `assets/game/world/` and normalized catalog | Candidate only after classification and license/provenance verification |
| Male/female multi-direction base | `assets/game/characters/base/` | Anatomy/style reference; distinct REALM player visual sets |

## Practical division
- **One style**: consistent illustration quality, chibi proportions, rendering/material and transparency.
- **Two visual identities**: BRAMBLE remains exploratory/open-world; REALM emphasizes staged tap-combat, loot/upgrades and hero growth.
- **One source provenance standard**: Source IDs, SHA hashes and license/origin records follow source files.
- **Two import adapters**: Assets are chosen, transformed and tested per game's rendering/camera/rig. No cross-repository runtime path imports or shared mutable binary files.

## Current gaps that prevent blind reuse
- The BRAMBLE monster animation matrix explicitly reports many missing walk/attack/hit/defeated directional cycles. Four directional idle sprites do not equal finished action animation.
- Equipment sprite presence does not prove that its grip connects to a specific REALM hero pose.
- Source/derived/master sheets are mixed in older collections; production should select verified singles.
- Asset rights/ownership provenance has not been checked for each file from this planning exercise. Commercial dual-use remains a review gate rather than an assumption.

## Change control
Never update `Bramble/main` or overwrite its original ZIPs as part of REALM asset integration. Reusable content is versioned with an explicit manifest and a product opt-in. Before copying any production texture, both games should review one rendered hero-weapon-VFX test at their own target cameras.
