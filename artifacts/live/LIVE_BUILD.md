BRAMBLE LIVE BUILD

Milestone: m04.31a
Commit: 4af0f55a39f09f7f24d4544c0c2c46903d73bb5a
Date: 2026-09-18
Godot: 4.7.2
Production Slice: res://scenes/world/amberway_moor_m04_30.tscn
Main Scene Smoke: PASS
M04.31A Smoke / Capture / Profile: PASS
Landscape Capture: artifacts/m04_31a/13_final_gameplay_landscape.png
Portrait Capture: artifacts/m04_31a/14_final_gameplay_portrait.png
Gameplay Capture: artifacts/m04_31a/09_player_equipment_attack.png

The existing `artifacts/live/latest_*.png` files contain preserved,
uncommitted M04.3 WIP and were intentionally not overwritten or staged.

Known Issues:
- Production decision B: one authored player/equipment attack-pose set remains.
- Android build is blocked by the missing export preset.
- Real-device validation is blocked by unavailable ADB/device access.
