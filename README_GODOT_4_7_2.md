# BRAMBLE V23.30 → Godot 4.7.2

Open `project.godot` in Godot 4.7.2.

## Equipment now included
- 4 armor families: forest, leather, knight, arcane.
- torso, head, boots+gloves layers.
- 8 weapon types.
- explicit per-pose attachment rig.
- `BrambleEquipmentRig` with Sprite2D layers.
- `BramblePlayerVisual` emits semantic pose changes to the rig.

The source manifest says the original equipment sheet is not natively overlay-ready.
Therefore this build uses a deliberate calibration rig rather than pretending the art already shares attachment anchors.

Next visual QA should tune each pose/socket on-device and later add additional facing directions.
