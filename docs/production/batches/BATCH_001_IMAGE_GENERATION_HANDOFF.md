# BATCH 001 — Image Generation Handoff

**Purpose:** Single self-contained brief for external image generation (ChatGPT / DALL·E / manual paint).  
**Authority:** Masterplan commit `29638ee`; M04.31B report; catalog assets A00107–A00114.  
**Output:** 2 production sheets → extract 16 PNGs + author 1 JSON from measured sockets.

---

## A. Canonical character appearance (male body)

**Identity:** BRAMBLE canonical male adventurer (Kit54 / A00107–A00114). Do not redesign.

| Feature | Specification |
|---|---|
| Style | 2D anime/chibi MMORPG sprite; clean dark-brown outlines; soft cel-shading; top-left key light |
| Proportions | ~3.5 heads tall; large head; sturdy limbs; big expressive eyes |
| Hair | Messy spiky medium-brown; prominent upward tuft at crown; frames face |
| Eyes | Large brown irises, white highlights; thick brows |
| Skin | Fair warm peach |
| Shirt | Cream/off-white short-sleeve; dark olive-green V-neck collar |
| Pants | Medium brown trousers, slightly baggy |
| Belt | Dark brown strap; tan **X** stitch buckle at front center |
| Boots | Dark brown leather; tan folded cuff; flat soles |
| Expression | Windup: focused/tense. Commit: exertion (mouth may open slightly on commit) |

**Forbidden on body layers:** armor, helmet, sword, shadows on ground, VFX, UI, text.

---

## B. Canonical Wayfarer appearance (armor overlay only)

From experimental atlas `assets/labs/m04_26/wayfarer_armor_8dir.svg` and equipped runtime captures.

| Part | Color | Notes |
|---|---|---|
| Tunic cloth | `#315c4b` | Forest green torso/sleeves |
| Outline | `#1b3029` | 4–5 px equivalent at 512 scale |
| Leather shoulders | `#75482f` | Side wraps; stroke `#39251c` |
| Gold trim | `#d5a649` | Lower hem band; stroke `#563d22` |
| Leaf emblem | `#6f9a52` | Center chest; deforms with torso twist |

**Helmet (DO NOT PAINT — reference only):** green cap `#315c4b`, brown band, gold trim, orange feather `#d9813a`. Existing asset attaches via JSON head socket.

**Sword (DO NOT PAINT — reference only):** canonical `short_sword.png` — silver blade, gold guard, green gems, brown grip. Attaches via JSON main_hand socket.

---

## C. Eight body pose descriptions

**Global pose rules:**

- Two-handed short-sword grip (empty hands shaped for hilt).
- **Windup** = anticipation / stored force (coiled, hands pulled back).
- **Commit** = strike release (extension toward target).
- Feet stay near y=468 ground line; ≥24 px transparent margin.
- Pivot `(256,468)` = midpoint between feet.

**Strike axis (screen space):**

| Direction | Character faces | Strike travels |
|---|---|---|
| `front` | Camera | Screen right (+X) |
| `right` | Profile right | Screen right (+X) |
| `back` | Away from camera | Screen left (−X) |
| `left` | Profile left | Screen left (−X) |

### C1. FRONT_WINDUP

- **Facing:** Full front view.
- **Torso:** Rotated ~25° CCW; left shoulder forward.
- **Head:** Faces camera; gaze toward screen-right.
- **Arms:** Both elbows bent; hands together at **left upper chest** (x≈210–230, y≈195–215).
- **Legs:** Wide stance; knees soft; weight on rear (right) leg.
- **Silhouette:** Compact triangle — hands high left, feet wide.

### C2. FRONT_COMMIT

- **Facing:** Full front.
- **Torso:** Lean ~15° toward screen-right.
- **Head:** Slight turn right; eyes on strike.
- **Arms:** Extended forward-right (x≈300–335, y≈230–255); near-straight elbows.
- **Legs:** Right foot forward; left leg back; weight forward.
- **Silhouette:** Long diagonal from back foot to front hands.

### C3. RIGHT_WINDUP

- **Facing:** 90° right profile (nose → +X).
- **Torso:** Coiled CCW; chest away from strike direction.
- **Head:** Profile; eye toward +X.
- **Arms:** Hands at **rear shoulder** (far side, x≈340–365, y≈175–200).
- **Legs:** Staggered; load on back leg.
- **Silhouette:** C-shape coil.

### C4. RIGHT_COMMIT

- **Facing:** Right profile.
- **Torso:** Drive forward +X.
- **Arms:** Lead arm fully extended +X (x≈380–410, y≈235–255).
- **Legs:** Deep front knee bend; rear leg trailing.
- **Silhouette:** Horizontal lunge line.

### C5. BACK_WINDUP

- **Facing:** Full back view.
- **Torso:** Rotated to load **right rear shoulder** toward camera.
- **Head:** Back of hair; slight turn toward strike side.
- **Arms:** Hands at right shoulder blade area (x≈290–315, y≈185–210).
- **Legs:** Wide; weight left.
- **Silhouette:** Mound at upper-right of back.

### C6. BACK_COMMIT

- **Facing:** Full back.
- **Torso:** Rotates into screen-left strike.
- **Arms:** Cross toward screen-left (x≈175–210, y≈220–250).
- **Legs:** Left foot steps screen-left.
- **Silhouette:** Diagonal slash across back plane.

### C7. LEFT_WINDUP

- **Facing:** 90° left profile (nose → −X). **Authored separately — do not mirror RIGHT.**
- **Arms:** Hands at rear shoulder (x≈145–170, y≈175–200).
- **Same coil logic as RIGHT_WINDUP** but left-facing anatomy.

### C8. LEFT_COMMIT

- **Facing:** Left profile.
- **Arms:** Extended −X (x≈95–125, y≈235–255).
- **Lunge −X** with authored left anatomy.

---

## D. Eight armor overlay descriptions

For each body pose above, paint **only** the Wayfarer armor pieces (§B) deformed to match that exact pose:

1. FRONT_WINDUP overlay → aligns BODY FRONT_WINDUP  
2. FRONT_COMMIT → BODY FRONT_COMMIT  
3. RIGHT_WINDUP → BODY RIGHT_WINDUP  
4. RIGHT_COMMIT → BODY RIGHT_COMMIT  
5. BACK_WINDUP → BODY BACK_WINDUP  
6. BACK_COMMIT → BODY BACK_COMMIT  
7. LEFT_WINDUP → BODY LEFT_WINDUP  
8. LEFT_COMMIT → BODY LEFT_COMMIT  

**Overlay rules:** Transparent outside armor pixels. No skin, hair, eyes, helmet, sword, shadow, or background. Leaf emblem stays on chest center mass. Gold hem follows torso bend. Leather shoulder wraps track deltoids.

**QA:** Overlay each armor PNG at 100% on its body PNG — zero visible gap at shoulders/sleeves/hem.

---

## E. Direction definitions

Camera-relative cardinals for M04.31B (not 8-diagonal):

```
        BACK
          ↑
   LEFT ← ● → RIGHT
          ↓
        FRONT
```

- **FRONT:** Character faces viewer (eyes visible).
- **RIGHT:** Right side profile; nose points right edge of canvas.
- **BACK:** Character faces away; back of head/hair dominant.
- **LEFT:** Left side profile; nose points left edge.

Diagonals are **not** authored; runtime uses nearest cardinal + procedural motion.

---

## F. Canvas / pivot rules

| Rule | Value |
|---|---|
| Canvas | 512×512 pixels |
| Alpha | Straight RGBA; no premultiplied fringe; no baked checkerboard |
| Pivot | `(256, 468)` — ground contact between feet |
| Padding | Minimum 24 px clear alpha around entire silhouette |
| Subject height | ~410 px standing (hair top ≈y55–70 to soles y468) |
| Horizontal center | Character mass centered on x=256 |
| Scale | Authored for runtime `pixel_size=0.0055` |
| Consistency | All 8 body poses = same character; all 8 armor = same gear |

---

## G. Sheet layout

**Recommendation:** Two sheets (quality over single-sheet compression).

### SHEET A — BODY (8 cells)

| | Col 1 | Col 2 | Col 3 | Col 4 |
|---|---|---|---|---|
| **Row 1 (windup)** | FRONT_WINDUP | RIGHT_WINDUP | BACK_WINDUP | LEFT_WINDUP |
| **Row 2 (commit)** | FRONT_COMMIT | RIGHT_COMMIT | BACK_COMMIT | LEFT_COMMIT |

### SHEET B — ARMOR (8 cells)

Identical grid and cell order as Sheet A.

**Dimensions (per Art Production Matrix):**

- Cell: 512×512  
- Gutter between cells: 32 px  
- Outer margin: 32 px  
- Sheet size: **2208 × 1120 px** (4 cols × 2 rows)

```
|--32--|512|--32--|512|--32--|512|--32--|512|--32--|  = 2208 width
|--32--|512|--32--| ... row1 ...
|--32--|512|--32--| ... row2 ...
|--32--|
= 1120 height
```

**Extraction:** Crop each cell losslessly to individual PNGs. No rescale. Preserve pivot at cell-local `(256,468)`.

**Forbidden on sheets:** overlapping glow, shared shadows between cells, text labels, presentation backgrounds, gradients behind characters.

---

## H. Forbidden content

Do **not** include in any PNG:

- Diagonal (FR/FL/BR/BL) attack poses
- New or alternate helmet art
- New or alternate sword art
- Recovery / followthrough / idle poses
- Ground shadows or floor textures
- Checkerboard or solid backdrop (full transparent except character)
- Text, watermarks, UI, grid lines (except temporary non-export guides)
- Mirrored copies of right poses for left poses
- VFX slashes, particles, motion blur

---

## I. Filenames

### Sheet cell labels (for artist reference)

`BODY_FRONT_WINDUP`, `BODY_FRONT_COMMIT`, … `BODY_LEFT_COMMIT`  
`ARMOR_FRONT_WINDUP`, … `ARMOR_LEFT_COMMIT`

### Runtime export filenames (lowercase)

| Direction | Windup | Commit |
|---|---|---|
| front | `front/windup.png` | `front/commit.png` |
| right | `right/windup.png` | `right/commit.png` |
| back | `back/windup.png` | `back/commit.png` |
| left | `left/windup.png` | `left/commit.png` |

---

## J. Target paths

**Body:**

```
assets/game/characters/base/male/actions/melee/<direction>/<pose>.png
```

**Armor:**

```
assets/game/characters/equipment/armor/wayfarer/actions/melee/<direction>/<pose>.png
```

**Metadata:**

```
data/spatial/player_actions/wayfarer_melee_attack.json
```

---

## K. Socket metadata requirements

**File:** `data/spatial/player_actions/wayfarer_melee_attack.json`  
**Authored after PNGs exist** — measure from final body art (top-left origin, +x right, +y down).

### Schema (compatible with planned presenter integration)

```json
{
  "schema_version": 1,
  "family_id": "wayfarer_melee_attack",
  "content_id": "EQ_T01",
  "canvas": { "width": 512, "height": 512 },
  "pivot": { "x": 256, "y": 468 },
  "pixel_size": 0.0055,
  "poses": {
    "<direction>": {
      "<pose>": {
        "head": { "x": 0, "y": 0, "rotation_deg": 0.0 },
        "main_hand": { "x": 0, "y": 0, "rotation_deg": 0.0 },
        "slash_origin": { "x": 0, "y": 0 },
        "helmet_rotation_deg": 0.0,
        "weapon_rotation_deg": 0.0,
        "weapon_depth": 3,
        "helmet_depth": 8,
        "confidence": "AUTHORED"
      }
    }
  }
}
```

**Directions:** `front`, `right`, `back`, `left`  
**Poses:** `windup`, `commit`  
**OFFHAND:** not used (two-hand grip).

### Depth table (render_priority semantics)

| Direction | Pose | `weapon_depth` | Notes |
|---|---|---:|---|
| front | windup | 3 | Sword in front of torso |
| front | commit | 3 | Crosses in front |
| right | windup | 3 | Profile — weapon forward |
| right | commit | 3 | Extended strike |
| back | windup | -1 | **Behind** torso at start |
| back | commit | -1 or 3 | May cross after impact; default -1 at commit keypose |
| left | windup | 3 | Profile |
| left | commit | 3 | Extended strike |

Helmet `helmet_depth`: always **8** (above body, below front VFX).

### Rotation guidance

- `weapon_rotation_deg`: align existing `short_sword.png` grip to hand vector (hilt → blade).
- `helmet_rotation_deg`: match head tilt per pose; 0° for front windup; slight ±5–15° on commits.
- Base idle weapon rotations in `m04_30_entity_profiles.json` (`rotation_by_direction`) are reference starting points only — **per-pose JSON overrides during attack**.

### Seed measurement workflow

1. Place body PNG in 512 canvas at pivot (256,468).
2. Mark `main_hand` at midpoint of clasped hands.
3. Mark `head` at center of cranium (helmet anchor).
4. Mark `slash_origin` 12–20 px beyond main_hand along strike vector.
5. Record `weapon_rotation_deg` that aligns sword asset visually.
6. Repeat for all 8 poses.

---

## L. Acceptance checklist

### Sheet / PNG technical

- [ ] Two sheets OR 16 individual 512×512 PNGs with identical specs
- [ ] Straight alpha; no background
- [ ] Pivot (256,468) on all 16 rasters
- [ ] ≥24 px transparent padding
- [ ] No mirroring between left and right

### Body (8)

- [ ] Same canonical male in all frames (face, hair, clothes, proportions, style)
- [ ] Windup vs commit clearly distinct in all 4 directions
- [ ] Anatomical coil/extension — not idle with moved arms only
- [ ] No armor, helmet, sword, shadow, VFX pixels

### Armor (8)

- [ ] Pixel-aligned overlay test passes on each body pair
- [ ] Only armor pixels; transparent elsewhere
- [ ] Leaf emblem and gold trim deform correctly

### JSON (1)

- [ ] 8 pose records complete
- [ ] Coordinates within canvas
- [ ] Depth follows table §K
- [ ] Parses as valid JSON

### Runtime intent (verified after import — not this generation step)

- [ ] Equipped Wayfarer attack reads at normal mobile zoom landscape + portrait
- [ ] Front/right sword in front; back windup sword behind
- [ ] Existing helmet + sword + slash VFX reuse without new art

---

## Reference asset paths (attach to image-gen session)

| Asset | Path |
|---|---|
| Male idle front | `assets/game/characters/base/male/directions/front.png` |
| Male idle right | `assets/game/characters/base/male/directions/right.png` |
| Male idle back | `assets/game/characters/base/male/directions/back.png` |
| Male idle left | `assets/game/characters/base/male/directions/left.png` |
| Kit88 windup (pose language) | `assets/game/characters/animations/male/attack_melee/01_male_windup.png` |
| Kit88 swing (pose language) | `assets/game/characters/animations/male/attack_melee/02_male_swing.png` |
| Wayfarer armor atlas | `assets/labs/m04_26/wayfarer_armor_8dir.svg` |
| Wayfarer helmet atlas | `assets/labs/m04_26/wayfarer_hat_8dir.svg` |
| Canonical sword | `assets/game/characters/equipment/weapons/melee/short_sword.png` |
| M04.31B equipped captures | `artifacts/m04_31b/02_attack_anticipation.png`, `03_attack_commit.png`, `07_attack_front.png`, `09_attack_rear.png` |

---

## Creation card index

Full per-asset cards: `docs/production/batches/BATCH_001_CREATION_CARDS.md`
