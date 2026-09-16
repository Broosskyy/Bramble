# M02.2 — Visual Production Pass

**Date:** 2026-09-16  
**Project:** `BRAMBLE_GAME/`  
**Engine:** Godot 4.7.2  
**Basis:** M02.1 Village→Transition→Wilds production world (unchanged scope)

---

## A. Screenshot Audit M02.1 (vor Änderungen)

Audit der vier M02.1-Screenshots (`artifacts/m02_1/`):

| # | Problem | Schwere |
|---|---------|---------|
| 1 | Sichtbares Grass-Tile-Raster / dunkle Nähte zwischen Kacheln | Hoch |
| 2 | Fluss als isolierte blaue Rechtecke mit Lücken | Hoch |
| 3 | Meadow-Overlay erzeugt rechteckige Patchwork-Felder | Mittel |
| 4 | Minimap leer (nur Bezel) | Hoch |
| 5 | Baum-Occlusion zu grob / fade bei unpassenden Positionen | Mittel |
| 6 | Portrait-Combat: Spieler hinter Bäumen ohne klare Occlusion | Mittel |
| 7 | Wege teilweise nicht mit `tile_step()` verbunden | Mittel |
| 8 | Dirt/Transition-Streifen fehlen an Cobble-Rändern | Mittel |
| 9 | Player/NPC nur Single-Frame + Bob, keine Production-Walk-Frames | Niedrig (asset-limited) |
| 10 | Moorling nur `kit60_front.png`, keine Zustandsanimation | Mittel |
| 11 | HUD grundsätzlich OK (M02.1 Fix), Minimap ohne Inhalt | Mittel |
| 12 | Dorf-Lanscape wirkt komponiert, Wilds noch dünn/patchy | Mittel |

---

## B. Terrain Fixes

| Fix | Implementierung |
|-----|-----------------|
| Terrain Pipeline | Neu: `scripts/terrain_tile_placer.gd` — Pixel-Snap, `TILE_BLEED_PX`, Layer-z, LINEAR filter |
| Kein Meadow-Tile-Grid | Entfernt: kein `meadow.png` Repeat-Overlay mehr (Ursache Patchwork) |
| Overlap | `TILE_OVERLAP = 1.015`, Bleed 2px (Wasser +4px) |
| Grass-Fill | Nur `grass_repeat_256.png` über volle Canvas-Fläche |
| Wege | `tile_step()` für Cobble statt hardcoded 118px |
| Fluss | `water_repeat_256.png` statt seamless river grid; Bank-Step aus Asset-Breite |
| Performance | Map-Paint nicht mehr pro Grass-Tile (nur semantische Zellen) |

---

## C. Transition Fixes

| Übergang | Maßnahme |
|----------|----------|
| Meadow → Cobble | Dirt-Shoulder-Streifen (`dirt_repeat_256`) links/rechts der Cobble |
| Meadow → Wilds | Fallen-leaves-Overlay-Band ab x≈320 |
| Ground → Riverbank | `riverbank_straight` + `river_edge` + `pond_edge_endcap` |
| h0 → h1 | Bestehend: ramp, stairs, grass_edge, elevation zone |

Keine neuen geslicten Assets — alle aus vorhandenen Production-Singles.

---

## D. Geslicte / neue Production Singles

**Keine.** Kein Source-Sheet in M02.2 verändert oder gesliced.

---

## E. Occlusion

`scripts/occlusion_manager.gd` überarbeitet:

- Pro-Objekt Metadaten: `occlusion_foot_y`, `occlusion_half_w`, `occlusion_height`
- Fade nur wenn Spieler **hinter** Canopy (Screen-Y kleiner als Foot, innerhalb Breite)
- Weiches Ein/Aus via `move_toward` (speed 8.0, alpha 0.52)
- Bäume/Gebäude mit kalibrierten Half-Width/Height pro Scale im World Builder

---

## F. Depth / Y-Sorting

- `footpoint_sort.gd`: nutzt `global_position.y + offset`, `z_as_relative = false`
- Entities (Player, NPC, Monster) behalten Footpoint-Child mit Auto-Update
- h1-Objekte auf `Elevated` mit `height_level = 1`

---

## G. Minimap

| Komponente | Pfad |
|------------|------|
| Map Registry | `scripts/world_map_registry.gd` |
| Runtime Renderer | `scripts/runtime_minimap.gd` |
| HUD Integration | `scripts/production_hud.gd` |

**Darstellung:** Meadow (grün), Road (beige), Water (blau), Dirt, Wilds, Elevation + Marker NPC (cyan), Portal (lila), Monster (rot), Player (gelb).

Abgeleitet aus World-Build-Daten — keine Fake-Textur.

---

## H. Player Animation

Geprüft gegen `assets/game/_catalog/CHARACTER_ANIMATION_MATRIX.md`:

| State | M02.2 Verhalten |
|-------|-----------------|
| Idle | 8-Richtungs-Production-Single-Frames |
| Move | Walk `walk_a`/`walk_b` nur für front/front_left/front_right; sonst Direction-Switch |
| Direction retention | Ja |
| Hit | `animations/hit.png` wenn `show_hit()` |
| Defeated | `animations/defeated.png` via `show_defeated()` |
| Run-Bob | Entfernt (ersetzt durch Walk wo konsistent) |

---

## I. Monster Presentation (Moorling)

`scripts/enemy.gd` — Production Moorling mit `AnimatedSprite2D`:

| State | Assets |
|-------|--------|
| Idle | Direction `kit60_{front,back,left,right}` + idle cycle 01–04 |
| Hit | hit_01–04 |
| Attack | attack_01–04 |
| Defeated | defeated_01–04 |
| HP-Bar | Nur Target/Aggro/Combat (`aggro_range * 0.65` oder Schaden) |
| Name-Label | Aus in Production |

---

## J. Portrait

- Gleicher GameState / Map / Collision / Minimap-Daten
- Eigenes HUD-Layout (Quest unter Status, Joystick unten links)
- Zoom `CAMERA_ZOOM_PORTRAIT = 1.06`
- Screenshots: `portrait_village.png`, `portrait_wilds.png`, `portrait_combat.png`

---

## K. Landscape

- Zoom `CAMERA_ZOOM_LANDSCAPE = 0.94`
- Screenshots: `landscape_village.png`, `landscape_wilds.png`, `landscape_combat.png`
- HUD ohne Overlap (M02.1 Layout beibehalten)

---

## L. Performance Sanity

| Metrik | Größenordnung |
|--------|----------------|
| Ground sprites | ~352 (22×16 grass repeat) |
| Road/water/overlay | ~80–120 zusätzlich |
| World objects | ~60–80 Sprites |
| Occlusion | O(occluders) pro Frame, ~12 Bäume |
| Minimap | 96×72 Image rebuild ~8/sec |
| World-Build `_ready` | ~2–120s je nach Map-Paint (optimiert: kein Grass-Paint) |

Größter Overdraw: dichter Grass-Repeat-Stack (akzeptabel für Mobile-M02).

---

## M. Runtime Tests

| Test | Ergebnis |
|------|----------|
| Godot 4.7.2 Display Start | OK |
| `--m02_2-capture` | OK (6 PNGs) |
| `--m02_2-capture walk` | OK (QA-Pfad Village→Wilds) |
| Production World aktiv | OK |
| Legacy F9 | OK |
| Networking/Authority | Unverändert |

```powershell
& "C:\Users\manue\Downloads\Godot-4.7.2\editor\Godot_v4.7.2-stable_win64.exe" `
  --path "BRAMBLE_GAME" res://scenes/main.tscn --m02_2-capture
```

---

## N. Screenshot Paths

| Datei | Inhalt |
|-------|--------|
| `artifacts/m02_2/landscape_village.png` | Dorfplatz, Fountain, NPCs, Wege, Minimap |
| `artifacts/m02_2/landscape_wilds.png` | Transition/Wilds, Portal, Bäume |
| `artifacts/m02_2/landscape_combat.png` | Moorling-Nähe |
| `artifacts/m02_2/portrait_village.png` | Portrait Dorf |
| `artifacts/m02_2/portrait_wilds.png` | Portrait Wilds |
| `artifacts/m02_2/portrait_combat.png` | Portrait Combat |

---

## O. Remaining Visual Problems

Ehrliche QA-Checkliste M02.2:

| Check | Status |
|-------|--------|
| Keine grauen/leeren Flächen | **OK** (Dorf/Wilds bedeckt) |
| Keine auffälligen Tile-Seams | **Teilweise** — Grass-Repeat-Muster noch sichtbar |
| Keine isolierten Terrain-Inseln | **OK** |
| Wege zusammenhängend | **OK** |
| Riverbank funktioniert | **Verbessert** — vereinzelt harte Flusskanten |
| Elevation lesbar | **OK** |
| Player/NPC/Monster Depth | **OK** |
| Tree Occlusion | **Verbessert** — Combat-Portrait noch hart |
| Minimap echte Daten | **OK** |
| Player/Portal/NPC Marker | **OK** |
| HUD Landscape/Portrait | **OK** |
| Combat lesbar | **Teilweise** |
| MMORPG-Zone statt Gallery | **OK** im Dorf, **Teilweise** Wilds |

---

## P. Missing Asset/Animation Requirements

| Entity | Fehlend |
|--------|---------|
| Player | 8-dir Walk/Run Production-Sequences |
| Player | Attack/Cast Production pro Richtung |
| NPC | Walk/Idle-Variationen |
| Moorling | Diagonal-Richtungen (nur 4-dir kit60) |
| Terrain | Dedizierte Meadow→Cobble Autotile-Singles (optional aus kit_16 sheet) |

---

## Q. Visual Foundation Lock Status

**`VISUAL_FOUNDATION_LOCKED = FALSE`**

**Begründung:** Runtime-Screenshots zeigen keine grauen Testfelder mehr und Minimap/Occlusion/HUD sind funktional, aber **fundamentale Terrain-Nähte am Fluss/Grass-Repeat** und **harte Occlusion in dichten Wilds-Combat-Frames** verhindern Freeze als Visual Foundation.

**Empfehlung M03:** Autotile-Terrain-Composer, 8-dir Player-Walk-Slice aus vorhandenen Sheets, Combat-Arena-Framing in Wilds, dann erneute Abnahme mit `VISUAL_FOUNDATION_LOCKED = TRUE`.

---

## Neue / geänderte Dateien

- `scripts/terrain_tile_placer.gd` (neu)
- `scripts/world_map_registry.gd` (neu)
- `scripts/runtime_minimap.gd` (neu)
- `scripts/visual_master_world_builder.gd`
- `scripts/world_presentation_config.gd`
- `scripts/occlusion_manager.gd`
- `scripts/footpoint_sort.gd`
- `scripts/production_hud.gd`
- `scripts/player_visual.gd`
- `scripts/enemy.gd`
- `scripts/bootstrap.gd`
- `docs/visual/WORLD_PRESENTATION_STANDARD.md` (neu)
