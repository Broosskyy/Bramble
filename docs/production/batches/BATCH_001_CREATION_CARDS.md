# BATCH 001 — Creation Cards (M04.31B Wayfarer Melee Attack Pack)

Authority: commit `29638ee`, `BRAMBLE_ASSET_CREATION_QUEUE.md` Batch 001  
Scope: 16 PNG + 1 JSON. No helmet, sword, recovery, shadow, VFX, or diagonal art.

---

## Global contract (all cards)

| Field | Value |
|---|---|
| Canvas | 512×512 RGBA, straight alpha |
| Pivot | `(256, 468)` — midpoint between planted feet |
| Padding | ≥24 px transparent on all sides |
| `pixel_size` | `0.0055` |
| Mirroring | **FORBIDDEN** |
| Strike axis | Screen +X for `front`/`right`; screen −X for `back`/`left` (matches `screen_sign_by_direction` in `m04_30_entity_profiles.json`) |
| Layer order | body → armor → helmet (existing) → sword (existing) → slash VFX (existing) |
| Timing | `windup` ≈ normalized 0.00–0.20; `commit` ≈ 0.42 impact window |

---

## CC_001A — Body PNGs (8)

### BODY_FRONT_WINDUP

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_BODY` |
| FILENAME | `windup.png` |
| STATE | `windup` |
| DIRECTION | `front` |
| TARGET PATH | `assets/game/characters/base/male/actions/melee/front/windup.png` |
| REFERENCE ASSETS | `characters/base/male/directions/front.png` (A00110); Kit88 `01_male_windup.png` (pose language only) |
| VISUAL DESCRIPTION | Canonical male adventurer: messy spiky brown hair, large brown eyes, fair skin, cream short-sleeve shirt with dark olive V-neck, brown trousers, brown belt with tan X buckle, brown boots with tan cuffs. Anime/chibi 3.5-head proportions, clean dark outlines, soft cel-shade, top-left light. |
| POSE DESCRIPTION | **Facing:** camera front. **Strike loads screen-left.** Wide planted stance (feet ~190px and ~322px apart at y468). Torso rotated ~25° counter-clockwise (left shoulder forward). Head faces camera; eyes toward screen-right target. Both forearms bent; **hands clasped at left upper chest / left shoulder height** (approx x210–230, y195–215) as if gripping an invisible hilt. Right shoulder dropped back; left hip carries weight. Chest compressed; visible anticipation coil. **Not idle:** elbows lifted, torso twisted, knees slightly bent. |
| SUBJECT BOUNDS | x≈120–392, y≈52–468 |
| GROUND CONTACT | Both soles flat; contact line y468 |
| HEAD SOCKET EXPECTATION | Crown center ≈(256, 108); record in JSON after paint |
| MAIN-HAND SOCKET EXPECTATION | Grip center ≈(220, 205); both hands overlap; record in JSON |
| DEPTH EXPECTATION | Body band 5; weapon will render in front at commit |
| ACCEPTANCE | Silhouette clearly windup; differs from idle; no armor/weapon pixels; pivot exact |

### BODY_FRONT_COMMIT

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_BODY` |
| FILENAME | `commit.png` |
| STATE | `commit` |
| DIRECTION | `front` |
| TARGET PATH | `assets/game/characters/base/male/actions/melee/front/commit.png` |
| REFERENCE ASSETS | A00110; Kit88 `02_male_swing.png` (force direction only) |
| POSE DESCRIPTION | **Facing:** camera front. **Strike releases screen-right.** Lead (right) foot forward (~x285); rear (left) leg extended back. Torso leans ~15° toward screen-right. Head turned slightly right; eyes on strike line. **Both arms extended forward-right** (hands ≈x300–335, y230–255) with clear diagonal strike corridor; elbows nearly straight. Chest open; hips rotated into strike. Center of mass over front foot. |
| SUBJECT BOUNDS | x≈110–400, y≈50–468 |
| GROUND CONTACT | Front foot flat y468; rear heel may lift ≤8px |
| MAIN-HAND SOCKET EXPECTATION | Grip ≈(318, 242) |
| DEPTH EXPECTATION | Weapon crosses **in front** of torso at commit |
| ACCEPTANCE | Clear extension vs windup; face readable; no weapon art in body |

### BODY_RIGHT_WINDUP

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_BODY` |
| FILENAME | `windup.png` |
| STATE | `windup` |
| DIRECTION | `right` |
| TARGET PATH | `assets/game/characters/base/male/actions/melee/right/windup.png` |
| REFERENCE ASSETS | `characters/base/male/directions/right.png` (A00113); Kit88 windup |
| POSE DESCRIPTION | **Facing:** pure right profile (nose points +X). Strike forward (+X). Feet staggered: rear foot back-left, front foot forward-right. Torso coiled **away from strike** — chest rotated CCW. **Hands together above rear shoulder** (far shoulder from viewer, ≈x340–365, y175–200). Head profile; eye toward +X. Rear leg straight; front knee bent loading weight back. |
| SUBJECT BOUNDS | x≈140–400, y≈55–468 |
| MAIN-HAND SOCKET EXPECTATION | ≈(352, 188) |
| ACCEPTANCE | Profile readable; coil visible; not idle side pose |

### BODY_RIGHT_COMMIT

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_BODY` |
| FILENAME | `commit.png` |
| STATE | `commit` |
| DIRECTION | `right` |
| TARGET PATH | `assets/game/characters/base/male/actions/melee/right/commit.png` |
| POSE DESCRIPTION | **Facing:** right profile. **Lunge +X.** Front leg deep bend; rear leg trailing. Torso drives forward; shoulders square to strike. **Lead arm fully extended +X** (hand ≈x380–410, y235–255); rear arm follows on hilt. Head aligned with strike. Strong diagonal from rear foot to front hand. |
| MAIN-HAND SOCKET EXPECTATION | ≈(395, 245) |
| DEPTH EXPECTATION | Weapon in front of body (viewer sees weapon line past chest) |
| ACCEPTANCE | Maximum reach +X; distinct from windup |

### BODY_BACK_WINDUP

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_BODY` |
| FILENAME | `windup.png` |
| STATE | `windup` |
| DIRECTION | `back` |
| TARGET PATH | `assets/game/characters/base/male/actions/melee/back/windup.png` |
| REFERENCE ASSETS | `characters/base/male/directions/back.png` (A00107) |
| POSE DESCRIPTION | **Facing:** camera back. **Strike releases screen-left (−X).** Load to screen-right (character's weapon side). Torso rotated so **right shoulder is nearer camera and drawn back**. Hands at **right rear shoulder** (≈x290–315, y185–210). Legs wide; weight on left foot. Head shows back hair; slight turn toward strike side. Green collar V visible at nape. |
| MAIN-HAND SOCKET EXPECTATION | ≈(302, 198) |
| DEPTH EXPECTATION | Weapon begins **behind** torso (depth −1 at windup) |
| ACCEPTANCE | Back silhouette; coil opposite −X strike |

### BODY_BACK_COMMIT

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_BODY` |
| FILENAME | `commit.png` |
| STATE | `commit` |
| DIRECTION | `back` |
| TARGET PATH | `assets/game/characters/base/male/actions/melee/back/commit.png` |
| POSE DESCRIPTION | **Facing:** back. **Strike sweeps screen-left.** Torso rotates into strike; **arms cross left across back plane** (hands ≈x175–210, y220–250). Left foot forward toward screen-left; right leg anchors. Shoulder line diagonal; visible force transfer. Hair and collar follow rotation. |
| MAIN-HAND SOCKET EXPECTATION | ≈(192, 238) |
| DEPTH EXPECTATION | Weapon may begin behind; cross toward −X; may clip in front only after impact (runtime) |
| ACCEPTANCE | Clear extension −X; not mirrored from front |

### BODY_LEFT_WINDUP

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_BODY` |
| FILENAME | `windup.png` |
| STATE | `windup` |
| DIRECTION | `left` |
| TARGET PATH | `assets/game/characters/base/male/actions/melee/left/windup.png` |
| REFERENCE ASSETS | `characters/base/male/directions/left.png` (A00109) |
| POSE DESCRIPTION | **Facing:** pure left profile (nose points −X). Strike forward (−X). Mirror-anatomy of RIGHT_WINDUP but **authored separately** (no flip). Hands at rear shoulder (≈x145–170, y175–200). Coiled torso; front knee bent. |
| MAIN-HAND SOCKET EXPECTATION | ≈(158, 188) |
| ACCEPTANCE | True left profile; not a flipped right PNG |

### BODY_LEFT_COMMIT

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_BODY` |
| FILENAME | `commit.png` |
| STATE | `commit` |
| DIRECTION | `left` |
| TARGET PATH | `assets/game/characters/base/male/actions/melee/left/commit.png` |
| POSE DESCRIPTION | **Facing:** left profile. **Lunge −X.** Lead arm extended left (hand ≈x95–125, y235–255). Rear leg trails right. Same energy as RIGHT_COMMIT but opposite facing. |
| MAIN-HAND SOCKET EXPECTATION | ≈(112, 245) |
| ACCEPTANCE | Maximum reach −X; anatomically left-authored |

---

## CC_001B — Wayfarer armor overlays (8)

Armor matches body cards **pixel-for-pixel** in pose. Only armor pixels; transparent elsewhere.

| Card | Matches body | FILENAME | TARGET PATH |
|---|---|---|---|
| ARMOR_FRONT_WINDUP | BODY_FRONT_WINDUP | `windup.png` | `assets/game/characters/equipment/armor/wayfarer/actions/melee/front/windup.png` |
| ARMOR_FRONT_COMMIT | BODY_FRONT_COMMIT | `commit.png` | `assets/game/characters/equipment/armor/wayfarer/actions/melee/front/commit.png` |
| ARMOR_RIGHT_WINDUP | BODY_RIGHT_WINDUP | `windup.png` | `assets/game/characters/equipment/armor/wayfarer/actions/melee/right/windup.png` |
| ARMOR_RIGHT_COMMIT | BODY_RIGHT_COMMIT | `commit.png` | `assets/game/characters/equipment/armor/wayfarer/actions/melee/right/commit.png` |
| ARMOR_BACK_WINDUP | BODY_BACK_WINDUP | `windup.png` | `assets/game/characters/equipment/armor/wayfarer/actions/melee/back/windup.png` |
| ARMOR_BACK_COMMIT | BODY_BACK_COMMIT | `commit.png` | `assets/game/characters/equipment/armor/wayfarer/actions/melee/back/commit.png` |
| ARMOR_LEFT_WINDUP | BODY_LEFT_WINDUP | `windup.png` | `assets/game/characters/equipment/armor/wayfarer/actions/melee/left/windup.png` |
| ARMOR_LEFT_COMMIT | BODY_LEFT_COMMIT | `commit.png` | `assets/game/characters/equipment/armor/wayfarer/actions/melee/left/commit.png` |

**Wayfarer visual identity (all armor cards):**

- Forest-green tunic body `#315c4b` with dark outline `#1b3029`
- Gold hem/collar trim `#d5a649` / stroke `#563d22`
- Brown leather shoulder wraps `#75482f` / `#39251c`
- Center chest leaf emblem `#6f9a52` (deforms with torso; never floating)
- Same lighting as body; no body skin, hair, helmet, sword, shadow, or VFX pixels
- Sleeves, shoulders, chest plate, belt line track underlying limb curves exactly

**Acceptance (all armor):** 100% overlay alignment test on body pair; alpha outside armor = 0; pivot `(256,468)` identical.

---

## CC_001C — Socket metadata JSON (1)

| Field | Value |
|---|---|
| ASSET_ID | `AST_M0431B_SOCKET` |
| FILENAME | `wayfarer_melee_attack.json` |
| TARGET PATH | `data/spatial/player_actions/wayfarer_melee_attack.json` |
| PURPOSE | Per-pose pixel sockets for existing helmet + short sword; depth + slash origin |
| SCHEMA | See `BATCH_001_IMAGE_GENERATION_HANDOFF.md` §K |
| OFFHAND | **Not required** — two-hand grip uses `main_hand` only |
| ACCEPTANCE | Valid JSON; 8 pose keys; all coordinates within 0–512; `confidence` marked `AUTHORED` after measurement from final PNGs |

**Post-art workflow:** Measure `head`, `main_hand`, `slash_origin` on each final body PNG; set `weapon_rotation_deg` and `helmet_rotation_deg` to match grip/natural helmet sit; set `weapon_depth` per depth table in handoff.

---

## Production sheets

| Sheet | Contents | Layout |
|---|---|---|
| SHEET A — BODY | 8 body PNGs | 2 rows × 4 cols; see handoff §G |
| SHEET B — ARMOR | 8 armor PNGs | Identical cell grid to Sheet A |

Extract losslessly to individual target paths. Do not ship sheets at runtime.
