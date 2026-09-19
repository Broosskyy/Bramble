# BRAMBLE Asset Creation Queue

Authority: execute top-to-bottom. Counts are authored output files, not content-family labels. `assets/game/_catalog/SEMANTIC_OVERRIDES.json` controls provenance: Kit21 is vegetation; canonical Moorling is Kit60/70/71. Visual-master PNGs are reference-only.

## Global sheet and extraction rules

- Deliver runtime files individually unless a batch explicitly requests a sheet. Sheets use true straight alpha, no background/labels, no overlaps or cross-asset shadows, consistent scale, 32 px cell gutters and 32 px outer margin.
- Maximum sheet populations: icons 24; static props 12; directional idles 8; animation keyposes 16; VFX 12. Character/equipment matching layers share identical cells. Bosses and anything over 768 px use dedicated sheets.
- Extraction is lossless RGBA to the exact target paths. Preserve pivots/sockets in JSON; do not infer directions by mirroring where forbidden.
- Mobile acceptance means readable at target gameplay zoom in 16:9 landscape and 9:16 portrait without silhouette ambiguity.

## BATCH 001 — M04.31B exact authored attack pack

- **Batch ID / goal / content:** `BATCH001`; close the sole M04.31A/B P1 art gap; `CLS_01` + `EQ_T01`.
- **Exact asset IDs / count:** `AST_M0431B_BODY` 8 PNG; `AST_M0431B_ARMOR` 8 PNG; `AST_M0431B_SOCKET` 1 JSON; **17 files**.
- **Directions / states / poses / frames:** front right back left; melee; windup and commit; one keypose per direction-state pair. No diagonals.
- **Variants / dimensions / alpha:** one male body and one matching Wayfarer overlay variant; 512x512 RGBA; straight alpha.
- **Spacing / padding / pivot:** individual files; at least 24 px transparent silhouette padding; identical ground pivot `(256,468)`.
- **Mirroring / layers:** mirroring forbidden. Body is base; armor contains only armor and follows limbs; existing helmet stays above body; existing sword uses depth metadata; existing slash remains VFX.
- **Sockets / metadata:** one JSON records per direction/pose hand `(x,y)`, sword angle, helmet anchor `(x,y)`, helmet angle, body/weapon depth and ground pivot.
- **Sheet policy / maximum / extraction:** no production sheet; source review sheet may contain at most 16 aligned cells; export each PNG directly with no crop or rescale.
- **Target paths:** `characters/base/male/actions/melee/<direction>/<windup|commit>.png`; `characters/equipment/armor/wayfarer/actions/melee/<direction>/<windup|commit>.png`; `data/spatial/player_actions/wayfarer_melee_attack.json`.
- **Dependencies / visual spec / card:** canonical male 8-direction body; current Wayfarer armor/helmet; canonical short sword; `VS_CHAR_01`; cards `CC_001A-C`.
- **Acceptance:** exactly 16 transparent PNGs + one valid JSON; body/armor pixels align; pivots identical; front/right commit sword in front; back starts behind; no new helmet sword recovery shadow VFX or diagonal art; normal-zoom landscape/portrait silhouette passes.

### CC_001A — Male Wayfarer melee body

- **Asset ID / name / category / used by / map-content:** `AST_M0431B_BODY`; Male Wayfarer Melee Body; PLAYER/ACTION_BODY; player presenter and `CLS_01`; vertical slice.
- **Visual description / style / silhouette:** canonical anime/chibi male; readable planted attack silhouette matching the current base. Windup compresses torso opposite strike with both hands near rear shoulder; commit drives torso/lead leg forward with a clear short-sword line and unobstructed face.
- **Proportions / material / color hierarchy:** exact canonical body proportions and palette; skin/clothing only; body remains subordinate to armor and weapon.
- **Scale / canvas / bounds / contact / pivot:** runtime `pixel_size=0.0055`; 512x512; >=24 px transparent padding; feet grounded at y468; pivot `(256,468)`.
- **Facing / pose / state / directions / count / purpose:** cardinal front/right/back/left; windup telegraph and commit strike; 2 x 4 = 8.
- **Timing / lighting / background / padding:** normalized idle→windup→commit→held engine follow-through→idle recovery; match canonical neutral lighting; transparent; >=24 px.
- **Sockets / layering / mirror / shadow / VFX:** annotate head hand ground and slash origin in `CC_001C`; body below armor/helmet/weapon; no mirror; no authored shadow; no VFX.
- **Procedural / mobile / references / exclude:** Godot supplies travel impact hold recovery and diagonal cardinal fallback; match `A00107..A00114`; exclude armor helmet sword shadow VFX labels/background.
- **Target / acceptance:** body target path above; all eight frames align and remain recognizable at gameplay zoom.

### CC_001B — Wayfarer melee armor overlays

- **Asset ID / name / category / used by / content:** `AST_M0431B_ARMOR`; Wayfarer Action Armor; EQUIPMENT/ACTION_OVERLAY; `EQ_T01`; vertical slice.
- **Visual/style/silhouette/proportions/material/color:** exact current Wayfarer armor silhouette/material/palette; sleeves shoulders chest and belt track `CC_001A` limbs exactly; transparent outside armor.
- **Scale/canvas/bounds/contact/pivot:** same scale and 512x512 canvas as body; >=24 px silhouette padding; visual feet alignment y468; pivot `(256,468)`.
- **Facing/pose/state/directions/count/purpose:** exact front/right/back/left windup+commit correspondence; 8 PNGs; prevent idle-shaped armor during attack.
- **Timing/lighting/alpha/padding:** pose-index lock to body; canonical lighting; straight alpha; >=24 px.
- **Sockets/layers/mirror/shadow/VFX:** inherit JSON sockets; above body and below existing helmet/sword as depth dictates; no mirror; no shadow/VFX.
- **Procedural/mobile/references/exclude:** engine supplies other phases; reference current Wayfarer set and `CC_001A`; exclude body helmet weapon shadow VFX.
- **Target/acceptance:** armor target path above; pixel registration passes by overlaying each pair at 100%.

### CC_001C — Wayfarer melee socket JSON

- **Asset ID / name / category / used by / content:** `AST_M0431B_SOCKET`; Wayfarer Melee Sockets; METADATA; presenter; `EQ_T01`.
- **Visual/style/silhouette/proportions/material/color:** not applicable; semantic metadata only.
- **Scale/canvas/bounds/contact/pivot:** coordinates in 512x512 source pixels; ground `(256,468)`.
- **Facing/pose/state/directions/count/purpose:** eight direction-pose records; bind existing helmet and sword without new textures.
- **Timing/lighting/alpha/padding:** normalized windup/commit selection; visual fields not applicable.
- **Sockets/layers/mirror/shadow/VFX:** hand and helmet coordinates/angles; body and weapon depth; ground and slash origin; no mirrored derivation; existing VFX only.
- **Procedural/mobile/references/exclude:** Godot interpolates and handles diagonals; references the 16 PNGs and existing equipment; exclude texture payloads.
- **Target/acceptance:** JSON target above; schema parses; every PNG pair has one complete record and no out-of-canvas coordinate.

## BATCH 002 — Player directional motion closure

- **ID/goal/content:** `BATCH002`; make base traversal and damage direction-bound; `CLS_01` player.
- **IDs/count:** `AST_PLAYER_LOCOMOTION` 64 PNG + `AST_PLAYER_DAMAGE` 16 PNG = **80**.
- **Directions/states/poses/files:** 8 directions; walk and run at 4 frames each; four cardinals for hit and defeated at 2 keyposes per state.
- **Variants/dimensions/alpha/spacing/padding/pivot:** canonical male; 512x512 straight-alpha individual PNGs; review sheets max16 with 32 px gutters/margin; >=24 px; `(256,468)`.
- **Mirror/layers/sockets/metadata:** no mirror; body layer; head/hand/VFX sockets follow body; one animation metadata JSON per state with fps/contact frames.
- **Sheets/extraction/path:** source review sheets permitted; extract losslessly to `characters/base/male/animations/<state>/<direction>/`; never use source sheet at runtime.
- **Dependencies/spec/card:** Batch001; `ANIM_PLAYER_01/02`; `CC_002`.
- **Acceptance:** no facing snap; fixed feet during contacts; walk 8 fps/run 10 fps; hit 0.2 s/defeated 0.6 s; mobile read in both orientations.

### CC_002 — Base motion and damage

- **Asset ID/name/category/used by/content:** both Batch002 IDs; Male Directional Motion; PLAYER/BASE_ANIMATION; movement/combat; all maps.
- **Visual/style/silhouette:** canonical male identity; locomotion has alternating readable contacts and restrained chibi bounce; hit recoils without changing facing; defeated settles inside bounds.
- **Proportions/material/color/scale:** exact canonical body; current materials/colors; `pixel_size=0.0055`.
- **Canvas/bounds/contact/pivot:** 512x512; >=24 px; contact foot remains at y468; `(256,468)`.
- **Facing/pose/state/count/purpose:** as batch fields; 80 PNGs total; direction-bound movement and feedback.
- **Timing/lighting/alpha/padding:** walk 8 fps; run 10 fps; damage timing above; canonical lighting; straight alpha.
- **Sockets/layer/mirror/shadow/VFX:** body only with metadata sockets; no mirror; engine shadow and current VFX.
- **Procedural/mobile/references/exclude:** Godot cycles/tweens only; reference catalog male walk/run/hit/defeated frames; exclude gear background labels baked effects.
- **Target/acceptance:** target above; loops have no foot drift and survive 25% preview scale.

## BATCH 003 — Mobile HUD orientation closure

- **ID/goal/content:** `BATCH003`; close authored mobile presentation; gameplay HUD/target/touch/minimap.
- **IDs/count:** `AST_UI_HUD_CORE`; **2 layout resources**: landscape and portrait.
- **Directions/states/poses/files:** no world direction; landscape/portrait states; static anchored layouts.
- **Variants/dimensions/alpha/spacing/padding/pivot:** responsive 16:9 and 9:16; source assets retain alpha; 8 dp minimum inter-control gap; safe-area padding; screen anchors replace pivot.
- **Mirror/layers/sockets/metadata:** mirroring allowed only for symmetric panels; screen layers HUD→target→skills→touch→modal; no sockets; metadata includes safe-area anchors and touch regions.
- **Sheets/extraction/path:** no new sheet and no raster extraction; compose existing catalog UI to `ui/layouts/gameplay_<orientation>.tres`.
- **Dependencies/spec/card:** Batch002 and existing `ui/hud`, `ui/touch`, `ui/target`, `ui/map`; `UI_MOBILE_01`; `CC_003`.
- **Acceptance:** no overlap at reference aspect ratios; 44 dp touch targets; player/target bars and primary attack always visible; minimap and quest affordance avoid notches.

### CC_003 — Responsive gameplay HUD

- **Asset/name/category/used by/content:** `AST_UI_HUD_CORE`; Mobile Gameplay HUD; UI; all moment-to-moment gameplay.
- **Visual/style/silhouette/proportions/material/color:** use existing BRAMBLE framed panels and readable warm/cool hierarchy; compact silhouette; no new art style.
- **Scale/canvas/bounds/contact/pivot:** responsive viewport; safe-area bounds; screen-space anchors; world contact not applicable.
- **Facing/pose/state/directions/count:** landscape and portrait; two resources; no animation pose.
- **Timing/lighting/background/padding:** 120 ms feedback transitions; UI lighting not applicable; transparent layers; 8 dp gaps and safe area.
- **Sockets/layers/mirror/shadow/VFX:** screen layers above; mirror symmetric frames only; no shadow/VFX beyond existing button feedback.
- **Procedural/mobile/references/exclude:** Godot anchors/containers/nine-slice; reference visual-master gameplay images without importing them; exclude reference crops decorative backgrounds and controls under safe areas.
- **Target/acceptance:** exact two paths; touch and readability checks above pass.

## BATCH 004 — Amberway NPC cast

- **ID/goal/content:** `BATCH004`; author all seven R01 quest/service NPC identities.
- **IDs/count:** `AST_NPC_R01_IDLE` scoped to `NPC_R01_01..07`; **56 PNGs**.
- **Directions/states/poses/files:** 8 directions; idle; one pose; seven variants.
- **Dimensions/alpha/spacing/padding/pivot:** 512x512 straight alpha; directional review sheet max8 with 32 px gutters/margin; >=24 px; `(256,468)`.
- **Mirror/layers/sockets/metadata:** conditional mirror only for proven symmetric costume; body/accessory layers may be baked after review; optional head/interaction sockets; per-NPC role and footpoint JSON.
- **Extraction/path:** extract each cell to `npcs/R01/<npc>/directions/<direction>.png`.
- **Dependencies/spec/card:** Batch003; merchant/blacksmith catalog sources; `NPC_01`; `CC_004`.
- **Acceptance:** 56 unique valid files; role recognizable at mobile zoom; direction and footpoint consistency; merchant/blacksmith provenance remains separate.

### CC_004 — R01 NPC directional idles

- **Asset/name/category/used by/content:** `AST_NPC_R01_IDLE`; Amberway NPC Cast; NPC/DIRECTIONAL; R01 quests shops services; `NPC_R01_01..07`.
- **Visual/style/silhouette:** anime/chibi villagers sharing Amberway materials but unique role silhouettes: guide satchel; merchant pack; smith apron; healer herb mantle; warden badge; scout hood; keeper key/lantern.
- **Proportions/material/color/scale:** player-compatible proportions; cloth/leather/wood/metal; role accent over Amberway ochre/green; player scale 0.95–1.05.
- **Canvas/bounds/contact/pivot:** 512x512; >=24 px; feet y468; `(256,468)`.
- **Facing/pose/state/count/purpose:** 8 directions; neutral service-ready idle; 56 files.
- **Timing/lighting/alpha/padding:** engine idle bob only; canonical world lighting; straight alpha.
- **Sockets/layers/mirror/shadow/VFX:** optional head and interaction marker; foot-depth sorting; conditional mirror only after asymmetry check; engine shadow; no VFX.
- **Procedural/mobile/references/exclude:** engine supplies bob/interaction marker; reference canonical merchant and blacksmith; exclude weapons unless role-required backgrounds labels shadows.
- **Target/acceptance:** exact R01 targets; each role passes silhouette and 8-direction spin review.

## BATCH 005 — R01 field enemy closure

- **ID/goal/content:** `BATCH005`; complete all eight Amberway standards including Moorling without replacing accepted canonical art.
- **IDs/count:** R01 scopes of `AST_MON_STD_IDLE` 32; `WALK` 128; `ATTACK` 64; `HIT` 32; `DEFEATED` 32 = **288 PNGs**.
- **Directions/states/poses/files:** four cardinals; idle1; walk4; attack windup+commit2; hit1; defeated1; eight monster variants.
- **Dimensions/alpha/spacing/padding/pivot:** 512x512 straight alpha; state sheets max16; 32 px gutters/margin; >=24 px; species contact pivot recorded in metadata.
- **Mirror/layers/sockets/metadata:** no mirror for asymmetric creatures; body/accent layers; attack hit loot and VFX sockets; state/fps/contact JSON per species.
- **Extraction/path:** `monsters/<content_id>/<state>/<direction>/<frame-or-pose>.png`; individual runtime files only.
- **Dependencies/spec/card:** Batch004; canonical Moorling Kit60/70/71 and copper mole Kit61/72/73; `MON_01..05`; `CC_005`.
- **Acceptance:** 288 expected outputs accounted; existing source may be retained only when it passes direction/state contract; no Kit21 use as Moorling; movement has no sliding; attack telegraph reads at mobile zoom.

### CC_005 — Standard monster state set

- **Asset/name/category/used by/content:** five R01-scoped register IDs; Amberway Standard Enemy Set; MONSTER; field combat/loot/quests; `MON_R01_01..08`.
- **Visual/style/silhouette:** original anime/chibi creatures with eight distinct silhouettes; Moorling preserves accepted look; attacks exaggerate anticipation and clear threat line.
- **Proportions/material/color/scale:** 0.55–0.9 player height; regional amber/green accents; material appropriate per species.
- **Canvas/bounds/contact/pivot:** 512x512; >=24 px; stable feet/base/hover contact stored per species.
- **Facing/pose/state/count/purpose:** four cardinals and nine outputs per direction; 36/species; 288 total.
- **Timing/lighting/alpha/padding:** idle hold/bob; walk 8 fps; attack family profile about 0.7 s; hit 0.2 s; defeated 0.5 s; canonical lighting and straight alpha.
- **Sockets/layers/mirror/shadow/VFX:** attack/hit/loot/VFX sockets; foot-depth sorting; no mirror unless species card explicitly certifies symmetry; engine shadow; existing slash/impact style only.
- **Procedural/mobile/references/exclude:** engine timing holds movement fade and particles; references canonical Moorling/copper mole; exclude presentation backgrounds labels baked shadows cross-cell glow and mislabeled Kit21 vegetation.
- **Target/acceptance:** exact monster paths; complete spin/state/contact review and catalog provenance check.

## BATCH 006 — Base classes and equipment foundation

- **ID/goal/content:** `BATCH006`; complete four base combat silhouettes and gear progression foundation.
- **IDs/count:** `AST_CLASS_C01_MELEE` 16; `C02_RANGED` 32; `C03_MAGIC` 32; `C04_SUPPORT` 32; `AST_EQ_ARMOR_BASE` 96; `AST_EQ_ACTIONS` 96; `AST_EQ_WEAPONS` 24 = **328 files**.
- **Directions/states/poses/variants:** cardinals for actions; 8-direction armor idles; four class action profiles; two body types where register states; six tiers/four weapon families.
- **Dimensions/alpha/spacing/padding/pivot:** character/armor 512x512; weapons source-fit; straight alpha; sheet rules global; >=24 px; `(256,468)` for bodies/armor and grip pivot for weapons.
- **Mirror/layers/sockets/metadata:** no character mirror; equipment/body/helmet/weapon depth; head/main/offhand/VFX; profile JSON.
- **Sheets/extraction/path:** max16 review cells; individual files to register `TARGET_PATH`.
- **Dependencies/spec/card:** Batches001-005; `CLASS_01..04`, `EQ_01..03`; `CARD_CLASS_TEMPLATE`, `CARD_EQ_TEMPLATE`.
- **Acceptance:** all 328 rows/files reconcile; socket overlays pass; four classes remain distinguishable in grayscale/mobile silhouette.

## BATCH 007 — First Mantles and companion onboarding

- **ID/goal/content:** `BATCH007`; ship `SP_C01_01`, `SP_C02_01`, `SP_C03_01`, `SP_C04_01`, `FAIRY_01..02`, `PET_01..03`, `PARTNER_01`.
- **IDs/count:** scoped `AST_SP_BODIES` 64; `AST_SP_ACTIONS` 128; `AST_SP_PORTRAITS` 8; fairies 56; pets 96; partner 72 = **424 files**.
- **Directions/states/poses/variants:** Mantle idle8 and action cardinals x4; companion profiles exactly as register; both player bodies.
- **Dimensions/alpha/spacing/padding/pivot:** Mantles/partner 512; pet/fairy 384; portraits1024; straight alpha; global spacing; >=24 px; species/body contact pivots.
- **Mirror/layers/sockets/metadata:** no Mantle/partner mirror; conditional symmetric companion mirror; body/equipment/glow depth; head/hands/skill/VFX metadata.
- **Sheets/extraction/path:** register target templates; max16 review cells and individual runtime outputs.
- **Dependencies/spec/card:** Batch006; `SP_01/02`, `PET_01`, `PARTNER_01`, `FAIRY_01`; standard templates.
- **Acceptance:** exact 424 files; transformation silhouette and each companion readable; no base-class silhouette reuse presented as a Mantle.

## BATCH 008 — Remaining regions and launch field roster

- **ID/goal/content:** `BATCH008`; R02-R05 maps/NPCs/standards/elites/minibosses and regional world variants.
- **IDs/count:** `AST_NPC_R02_R05_IDLE` 224; remaining standard monsters 1,152; all elites 360; minibosses 220; vegetation 60; props 50; portal state set 12 = **2,078 files**.
- **Directions/states/poses/variants:** NPC8; monsters/cardinal state contracts; environment static/state variants per register.
- **Dimensions/alpha/spacing/padding/pivot:** 512 character/monster; miniboss768; source-native environment; straight/mixed alpha per register; global sheets; contact pivots.
- **Mirror/layers/sockets/metadata:** character mirror policies from templates; environment footpoint/occlusion metadata; combat sockets.
- **Extraction/path:** exact register targets grouped R02→R03→R04→R05; never treat source sheets as runtime.
- **Dependencies/spec/card:** Batch007; regional content register; `CARD_NPC/MON/BOSS/ENV_TEMPLATE`.
- **Acceptance:** all 25 maps have a coherent regional kit and linked cast; 40 standards/10 elites/5 minibosses reconcile; repaired semantic overrides pass.

## BATCH 009 — Dungeons and remaining Mantles

- **ID/goal/content:** `BATCH009`; six dungeons/bosses plus `SP_C01_02`, `SP_C02_02`, `SP_C03_02`, `SP_C04_02`, remaining companions.
- **IDs/count:** dungeon kits72; dungeon bosses312; scoped Mantle bodies64/actions128/portraits8; pets160; partner216; fairies112 = **1,072 files**.
- **Directions/states/poses/variants:** exact register contracts; six environment kits; six boss families; four Mantles; remaining companion IDs.
- **Dimensions/alpha/spacing/padding/pivot:** dungeon source-native; bosses1024; character512; companion384/512; global alpha/sheet/padding; recorded contacts.
- **Mirror/layers/sockets/metadata:** no bosses/Mantles/partners mirror; layers and mechanics sockets; dungeon collision/occlusion metadata.
- **Extraction/path:** register targets; source sheets Kit13/14/15 are provenance only and must be extracted.
- **Dependencies/spec/card:** Batch008; `CARD_DGN/BOSS/SP/COMPANION_TEMPLATE`.
- **Acceptance:** six playable visual kits and boss sets; all eight Mantles/eight pets/four partners/six fairies accounted.

## BATCH 010 — Raids PvP endgame and launch presentation

- **ID/goal/content:** `BATCH010`; three raids/bosses three PvP modes endgame UI icons VFX and projectiles.
- **IDs/count:** raid kits48; raid bosses216; PvP9; UI screens68; item icons180; skill icons80; skill VFX240; projectiles48 = **889 files**.
- **Directions/states/poses/variants:** raid and boss contracts; portrait/landscape UI; icon singles; VFX three-phase; projectile flight/impact.
- **Dimensions/alpha/spacing/padding/pivot:** register dimensions; global sheet limits; safe-area UI; VFX/socket pivots and arena footprints.
- **Mirror/layers/sockets/metadata:** VFX behind/front; raid mechanic sockets; responsive UI layers; no boss mirroring.
- **Extraction/path:** exact register targets; icons max24/sheet and VFX max12/sheet; individual runtime export.
- **Dependencies/spec/card:** Batch009; all raid/PvP/endgame content IDs; `CARD_RAID/BOSS/PVP/UI/ICON/VFX_TEMPLATE`.
- **Acceptance:** three raid and three PvP visual packages load in both orientations; every endgame content row has a referenced asset family; launch register reaches no untriaged status.

## Queue reconciliation

The ten batches sum to **5,234** net-new scoped files (batches 001–010). The register lists **5,330** total deliverables including **96 READY** catalog files that batches must mark **reuse** rather than regenerate. The **5,259** authored raster PNG count excludes 1 JSON and 70 UI layout resources per the Art Production Matrix counting rules. Queue totals are workload scopes, not a second budget.
