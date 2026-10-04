# BATCH 001 Reference Board

**File:** `BATCH_001_REFERENCE_BOARD.png`  
**Purpose:** External image-generation reference for BRAMBLE Batch 001 production.  
**Status:** Reference material only — **not** a runtime asset.

## Board layout

| Row | Panels | Role |
|-----|--------|------|
| Top | FRONT, RIGHT, BACK, LEFT | **Canonical identity + directional appearance** |
| Bottom | WINDUP, SWING | **Pose / motion reference only** |

## How to use this board

### Canonical character (FRONT / RIGHT / BACK / LEFT)

These four directional sprites define the **canonical BRAMBLE male adventurer**:

- anime/chibi MMORPG sprite
- ~3.5 heads tall
- large head, sturdy limbs
- expressive brown eyes
- messy/spiky medium-brown hair with characteristic upward crown tuft
- cream/off-white short-sleeve shirt
- dark olive V-neck collar
- medium-brown slightly baggy trousers
- dark-brown belt with tan X-stitch buckle
- dark-brown boots with tan folded boot cuffs

All Batch 001 authored action art must preserve this identity and directional appearance.

### Pose references (WINDUP / SWING)

`01_male_windup.png` and `02_male_swing.png` illustrate **attack motion language only**.

They do **not** override canonical identity, proportions, clothing, or directional appearance. They inform windup/commit timing and body attitude for new action frames.

## Batch 001 production target

Batch 001 requires **new authored windup/commit action art** (cardinals only: front, right, back, left × windup, commit).

Target **body** sprites must contain:

- **NO** sword
- **NO** armor
- **NO** helmet
- **NO** VFX

Hands must nevertheless form a convincing two-handed grip around an **invisible short-sword hilt**.

**LEFT** must be independently authored — **not** a mirrored RIGHT.

## Source files on this board

| Label | Source path |
|-------|-------------|
| FRONT | `assets/game/characters/base/male/directions/front.png` |
| RIGHT | `assets/game/characters/base/male/directions/right.png` |
| BACK | `assets/game/characters/base/male/directions/back.png` |
| LEFT | `assets/game/characters/base/male/directions/left.png` |
| WINDUP | `assets/game/characters/animations/male/attack_melee/01_male_windup.png` |
| SWING | `assets/game/characters/animations/male/attack_melee/02_male_swing.png` |

Source artwork on the board is presented without repainting, mirroring, color correction, or pose alteration. Sprites are uniformly scaled for readability; transparent regions remain transparent.
