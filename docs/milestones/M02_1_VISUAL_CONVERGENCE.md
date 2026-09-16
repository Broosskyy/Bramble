# M02.1 — Visual Convergence

**Date:** 2026-09-15  
**Project:** `BRAMBLE_GAME/`  
**Engine:** Godot 4.7.2  
**Scope:** Visual composition, scale master, HUD recomposition, camera calibration — no gameplay/network rewrites.

---

## A. Vorherige sichtbare Probleme (M02)

| Problem | M02-Zustand |
|---------|-------------|
| Graue/leere Flächen | Große unbedeckte Viewport-Bereiche, Clear Color sichtbar |
| Isolierte Terrain-Kacheln | Gras/Wege als lose Inseln auf grauem Hintergrund |
| Asset-Gallery-Wirkung | Gebäude/Props ohne Wege, Gärten, Übergänge |
| Skalierung | Miniaturhäuser neben übergroßen Figuren, winzige Bäume |
| Höhe | h0/h1 schwach lesbar, Cliff/Rampen dekorativ |
| Vegetation | Geringe Dichte, wenig Rahmung |
| HUD | Vollbild-UI-Frames (`kit78`, `world_map_frame`) überdeckten Welt + Joystick |
| Kamera | Zu weit herausgezoomt, Player klein |

---

## B. Verwendete Assets (Production-Singles)

Alle Pfade relativ zu `assets/game/`.

### Terrain / Wege / Wasser
| Rolle | Pfad |
|-------|------|
| Meadow base | `world/terrain/materials/grass_repeat_256.png` |
| Meadow overlay | `world/terrain/seamless/meadow.png` |
| Grass clumps | `world/terrain/overlays/overlay_grass_clumps_256.png` |
| Dirt patches | `world/terrain/materials/dirt_repeat_256.png` |
| Fallen leaves | `world/terrain/overlays/overlay_fallen_leaves_256.png` |
| Cobble road | `world/roads/road_cobble.png` |
| Road cross | `world/roads/road_cross.png` |
| Road bend | `world/roads/road_bend.png` |
| River water | `world/terrain/seamless/river.png` |
| Riverbank | `world/roads/riverbank_straight.png` |
| River corner | `world/roads/river_corner.png` |

### Gebäude / Props / Vegetation
| Rolle | Pfad |
|-------|------|
| Inn | `world/buildings/inn.png` |
| Workshop | `world/buildings/workshop.png` |
| Cottage | `world/buildings/cottage.png` |
| Fountain | `world/buildings/town_fountain.png` |
| Well | `world/buildings/village_well.png` |
| Garden | `world/buildings/garden.png` |
| Flower bed | `world/buildings/flower_bed.png` |
| Hay / cart / lantern / bench | `hay_bales.png`, `produce_cart.png`, `lantern_post.png`, `bench_crates.png` |
| Signpost | `blank_signpost.png`, `blank_sign.png` |
| Fences / gate | `fence_straight.png`, `fence_corner.png`, `gate_fence.png` |
| Bridge | `stream_bridge.png` |
| Trees / shrubs | `red_oak.png`, `apple_tree.png`, `golden_shrubs.png` |
| Transition stall | `market_stall.png` |
| Wilds arch | `ruined_arch.png` |
| Portal visual | `world/portals/portal_arch_active.png` |

### Elevation
| Rolle | Pfad |
|-------|------|
| Cliff / ledge / edge | `world/elevation/cliff_wall.png`, `earth_ledge.png`, `grass_edge.png` |
| Ramp / stairs | `earthen_ramp.png`, `embedded_stone_stairs.png` |
| Watchtower | `world/buildings/watchtower.png` |

### Entities
| Rolle | Pfad |
|-------|------|
| Player (8 dir) | `characters/base/male/directions/*.png` |
| NPC merchant | `npcs/merchant/directions/front.png` |
| NPC blacksmith | `npcs/blacksmith/directions/front.png` |
| Monster Moorling | `monsters/moorling/directions/kit60_front.png` |

### HUD (kompakt skaliert)
| Rolle | Pfad |
|-------|------|
| Status panel | `ui/hud/player_status_panel.png` |
| Quest tracker | `ui/quests/quest_tracker_panel.png` |
| Minimap bezel | `ui/map/kit62_minimap_bezel.png` |
| Joystick | `ui/hud/kit62_virtual_joystick.png` |
| Attack | `ui/hud/primary_attack_button.png` |

**Nicht als HUD-Widget verwendet (Modal-Assets):** `ui/quests/kit78_quest_log_panel.png`, `ui/quests/world_map_frame.png`, `ui/touch/item_slot.png` — zu groß für Overlay-HUD.

---

## C. Neu geslicte Assets

Keine Sheet-Slices in M02.1 erforderlich. Alle Vegetations- und Welt-Elemente existierten bereits als Production-Singles im Katalog (`assets/game/_catalog/ASSET_MANIFEST.csv`). Source Sheets unverändert.

---

## D. World Composition

Kompakte **Village → Transition → Wilds**-Zone in `scripts/visual_master_world_builder.gd`:

| Zone | Inhalt |
|------|--------|
| **Village** | Inn, Workshop, Cottage, Dorfplatz/Fountain, NPC-Bereich (Lina/Ferro), Cobble-Kreuzung, Zäune, Garten, Marktprops, Bäume/Sträucher |
| **Transition** | Marktstand, Wegverlauf Richtung Osten, dichtere Vegetation, Fluss mit Brücke |
| **Wilds** | Ruinenbogen, Moorling-Spawns, Portal/Nebelbruch, dichte Bäume/Felsen |

**Canvas-Fill:** `WORLD_FILL_ORIGIN (-1680,-1180)`, `22×16` Kacheln — gesamte Kamerafläche als komponierter Boden statt Testfeld.

---

## E. Scale Master

Zentral in `scripts/world_presentation_config.gd`:

| Kategorie | Wert | Anwendung |
|-----------|------|-----------|
| `SCALE_PLAYER` | 0.58 | Player visual |
| `SCALE_NPC` | 0.46 | Lina, Ferro |
| `SCALE_MONSTER_SMALL` | 0.52 | Moorling |
| `SCALE_BUILDING_SMALL` | 0.92 | Workshop, Cottage, Watchtower |
| `SCALE_BUILDING_LARGE` | 1.08 | Inn |
| `SCALE_TREE` | 0.82 | Red oak, apple tree |
| `SCALE_SHRUB` | 0.58 | Golden shrubs, flower bed |
| `SCALE_PROP_SMALL` | 0.50 | Signs, fences, crates |
| `SCALE_PROP_LARGE` | 0.64 | Fountain, bridge, stall |
| `SCALE_TERRAIN` | 0.68 | Ground tiles |
| `SCALE_ROAD` | 0.74 | Cobble / banks |
| `SCALE_WATER` | 0.70 | River |
| `SCALE_ELEVATION` | 0.78 | Cliff, ramp, stairs |
| `SCALE_PORTAL` | 0.80 | Portal arch |
| `TILE_OVERLAP` | 1.02 | Nahtlose Boden-Kacheln |

Legacy-Aliase (`PLAYER_VISUAL_SCALE`, `NPC_SCALE`, …) bleiben für Entity-Skripte.

---

## F. Terrain

- Vollständiger **Grass-Repeat + Meadow**-Untergrund mit Overlap
- Organische **Cobble-Wege** (Kreuzung Dorfplatz, Bogen Richtung Wilds, Nordarm)
- **Fluss** mit `tile_step()`-basiertem Water/Bank-Tiling (kein festes 112px-Raster mehr)
- **Brücke** (`stream_bridge`) eingebettet
- Variation: Grass clumps, Dirt, Fallen leaves sparsam verteilt

---

## G. 2.5D / Depth / Elevation

- Bestehendes **Footpoint-Sort** (`footpoint_sort.gd`, `SORT_HEIGHT_BIAS=512`)
- **Occlusion** für Bäume (`occlusion_manager.gd`)
- **h1-Zone** Shrine-Ledge: Cliff wall, Earth ledge, Grass edge, Watchtower, Ramp, Stairs, `ElevationZone`
- Kamera: feste schräge Oblique-Ansicht gemäß `assets/game/references/WORLD_CAMERA_SPEC.md` — keine freie Rotation

---

## H. Entity Presentation

| Entity | Änderung |
|--------|----------|
| **Player** | 8-Richtungs-Production-Sprites, Idle-Richtung bleibt, subtiler Run-Bob (`player_visual.gd`) |
| **NPC** | Production-Sprites, Footpoint, Name/Questmarker über Figur |
| **Moorling** | Production-Sprite, skaliert; Name-Label aus in Production; HP-Bar nur bei Aggro/Schaden |

**Fehlende Walk-Cycles:** Keine vollständigen richtungsabhängigen Animations-Sequenzen — nur Direction-Switching + Bob (siehe N).

---

## I. Landscape HUD

`scripts/production_hud.gd` — feste Display-Größen (`EXPAND_IGNORE_SIZE`):

| Zone | Position |
|------|----------|
| Status (240×86) | Oben links |
| Quest tracker (300×70) | Links unter Status |
| Minimap (132×104) | Oben rechts |
| Joystick (136×136) | Unten links (unter Quest-Zone) |
| Attack + Skills 1–3 | Unten rechts |

Joystick überdeckt weder Status noch Quest.

---

## J. Portrait HUD

Gleiche Systeme, angepasste Offsets:
- Status `(16, 48)`
- Quest `(16, 144)`
- Joystick `(16, bottom - margin)`
- Combat rechts unten

Orientation über `orientation_service.gd` + `_apply_layout()`.

---

## K. Runtime Tests

| Test | Ergebnis |
|------|----------|
| Godot 4.7.2 Start mit Display | OK |
| `--m02_1-capture` Bootstrap | OK — 4 PNGs geschrieben |
| Production World aktiv | OK |
| Legacy Gallery (F9) | OK — unverändert |
| Gameplay/Authority/Networking | Unverändert — nicht angetastet |

```powershell
& "C:\Users\manue\Downloads\Godot-4.7.2\editor\Godot_v4.7.2-stable_win64.exe" `
  --path "BRAMBLE_GAME" res://scenes/main.tscn --m02_1-capture
```

---

## L. Screenshot-Pfade

| Datei | Beschreibung |
|-------|--------------|
| `artifacts/m02_1/landscape_village.png` | Dorfplatz, Fountain, NPCs, Wege |
| `artifacts/m02_1/landscape_wilds.png` | Transition/Wilds, Portal, Bäume |
| `artifacts/m02_1/portrait_village.png` | Portrait Dorf |
| `artifacts/m02_1/portrait_combat.png` | Portrait nahe Moorling/Arch |

---

## M. Verbleibende sichtbare Probleme

Ehrliche QA gegen die 12-Punkte-Checkliste:

| # | Kriterium | Status |
|---|-----------|--------|
| 1 | Grauer/leerer Hintergrund | **Verbessert** — Dorf-Lanscape größtenteils bedeckt; vereinzelt dunkle Nähte an Tile-Grenzen in Wilds/Portrait |
| 2 | Terrain-Inseln | **Behoben** im Dorfzentrum; Transition noch teilweise Patchwork |
| 3 | Textur-Nähte | **Teilweise** — Grass-Repeat-Muster sichtbar, Fluss deutlich besser als M02 |
| 4 | Figurenmaßstab | **Verbessert** — Player/NPC/Gebäude näher an MMORPG-Verhältnis |
| 5 | Gebäude | **Verbessert** — Inn/Workshop lesbar, Seiten sichtbar |
| 6 | Vegetation | **Verbessert** — höhere Dichte Village→Wilds |
| 7 | Depth Sorting | **Funktional** — Bäume okcluden; Wilds-Combat-Shot teils harte Baumüberdeckung |
| 8 | Elevation | **Sichtbar** — Watchtower-Ledge erkennbar, noch nicht cinematic |
| 9 | HUD Overlap | **Behoben** — kein Vollbild-Modal mehr |
| 10 | Portrait spielbar | **Ja** — Joystick/Combat getrennt |
| 11 | Landscape spielbar | **Ja** |
| 12 | MMORPG-Welt statt Gallery | **Deutlich verbessert** — Dorf wirkt komponiert; Wilds noch content-dünner |

**Fazit M02.1:** Technisch abgeschlossen mit Pflicht-Screenshots. Visuelle Abnahme für Production-World: **Teilweise** — Dorf-Landscape nahe Ziel; Wilds/Tile-Nähte und Minimap-Inhalt offen.

---

## N. Fehlende Produktionsanimationen

| Entity | Fehlend |
|--------|---------|
| Player | Richtungsabhängiger Walk-Cycle (nur Single-Frame pro Richtung) |
| Player | Attack/Hit Production-Frames |
| NPC | Richtungs-/Idle-Variationen (nur `front.png`) |
| Moorling | Walk/Attack/Hit Cycles (nur `kit60_front.png`) |

Dokumentiert — keine erfundenen Frames.

---

## O. Empfehlung für M03

1. **Terrain Pipeline:** Dedizierter Tile-Composer oder Autotile-Regeln für Grass/Road/Water — eliminiert verbleibende Nähte ohne manuelles Overlap-Tuning.
2. **Minimap:** Echte Welt-Miniatur (`ui/map/world_map.png`) in `kit62_minimap_bezel` rendern.
3. **Animation Pass:** Player 8-dir Walk + NPC/Monster mindestens 4-dir aus vorhandenen Sheets slicen.
4. **Wilds Dichte:** Zweite Prop-Schicht (Rocks, Bushes, Pfosten) + Combat-Arena-Komposition für Portrait-Combat-Framing.
5. **Elevation Polish:** h1-Navmesh + sichtbarere Schatten/Kanten an Cliff/Ramp.
6. **Erst danach:** Networking/Authority/Content-Systeme (PostgreSQL, NosCore, SoM) — wie in M02.1 ausgeschlossen.

---

## Geänderte Dateien (M02.1)

- `scripts/world_presentation_config.gd` — Scale Master, Canvas, Camera, HUD margins
- `scripts/visual_master_world_builder.gd` — Vollständiger World-Rebuild
- `scripts/production_hud.gd` — Kompaktes HUD ohne Modal-Frames
- `scripts/bootstrap.gd` — `--m02_1-capture`
- `scripts/player_visual.gd` — Run-Bob
- `scripts/enemy.gd` — Production HP/Name
- `scripts/npc.gd` — NPC scale tweak
- `project.godot` — Clear color
- `scenes/main.tscn` — Player scale 0.58
