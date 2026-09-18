BRAMBLE LIVE BUILD

Milestone: m04.30
Commit: 4df681f2a6e9c58409b303410899ba5b7f3e5c81
Date: 2026-09-18
Godot: 4.7.2
Production Slice: res://scenes/world/amberway_moor_m04_30.tscn
Main Scene Smoke: PASS
M04.30 Smoke / Capture / Profile: PASS
Landscape Capture: artifacts/m04_30/27_final_playable_landscape.png
Portrait Capture: artifacts/m04_30/26_final_progression_portrait.png
Gameplay Capture: artifacts/m04_30/32_final_combat_portrait.png

The existing `artifacts/live/latest_*.png` files contain preserved,
uncommitted M04.3 WIP and were intentionally not overwritten or staged.

Known Issues:
- Production decision C: painterly Hall and authored equipment action poses
  require another focused convergence pass.
- Android build is blocked by the missing export preset.
- Real-device validation is blocked by unavailable ADB/device access.
