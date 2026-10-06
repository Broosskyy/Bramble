# Kein Name Core Port — Fusion Reset

This replaces the earlier "Bramble + Kein-Name-like rules" approach with the architecture that actually existed in Kein Name.

## Source truth recovered from Kein Name

The Kein Name repository already contained:

- hybrid Three.js/Pixi world rendering with real perspective geometry;
- planar gameplay simulation separated from rendering;
- simulation X/Y mapped to 3D X/Z with Y reserved for elevation;
- camera-relative 360-degree movement;
- acceleration, deceleration and stronger turn acceleration;
- a real local dash;
- free perspective camera orbit/pitch and user-owned zoom;
- 2D production-character art presented as billboards inside the 3D world;
- world-space combat, loot and progression layered on that simulation.

The Godot fusion must preserve those principles rather than treating the old Bramble 2D scene as the final presentation.

## Godot port boundary

Bramble's existing 2D CharacterBody2D, enemy state, combat, progression, inventory, quests and online/authority services remain the planar gameplay simulation.

The visible renderer is now a separate BrambleHybridWorld3D presentation layer:

- planar Vector2 simulation -> perspective Node3D world;
- simulation X/Y -> render X/Z;
- real PlaneMesh/BoxMesh terrain, roads, river, bridge and elevation masses;
- Bramble production art -> Sprite3D billboards for landmarks, player, enemies, NPCs and loot;
- Camera3D follow with movement look-ahead;
- free orbit/pitch and pinch/wheel zoom;
- camera-relative joystick/WASD input;
- combat taps ray-project through Camera3D back onto planar simulation;
- the old Camera2D/VisualMasterWorld remains available as underlying simulation/reference but is not the primary view.

## Current gate

This is a foundation pass, not visual completion. Exit criteria:

1. joystick up remains visually up on screen at any camera yaw;
2. all analog directions and diagonals work with acceleration/braking;
3. player cannot disappear because the camera is a real follow camera;
4. drag rotates/pitches the perspective camera and pinch/wheel changes distance;
5. village/wilds have real depth/parallax rather than a flat top-down canvas;
6. player/enemies/NPCs/loot are visible in the 3D world while Bramble systems still own state;
7. Web and Android build from the same Godot code.

After this gate we port the remaining Kein Name feel systems: directional hero presentation relative to camera, dash VFX, attack/projectile vocabulary, loot arcs/beams, camera impulse, responsive HUD and raid/world content.
