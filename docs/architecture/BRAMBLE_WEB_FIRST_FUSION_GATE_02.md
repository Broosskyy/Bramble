# Bramble Web-First Fusion Gate 02

Date: 2026-10-05

Engine: Godot 4.7.2 stable

Baseline: `main` after Gate 01 (`0cb82a8` and later)

## Purpose

Gate 01 proves Bramble **can** ship as a Godot Web export. Gate 02 proves it **plays acceptably** in a real mobile browser (portrait/landscape, touch, PWA, safe areas, no hangs) and moves the **startup budget** toward **&lt; 35 MiB** estimated gzip transfer.

No new maps, classes, shops, or Kein-Name combat parity in this gate.

## Scope (from product sequence)

### 1. Web build online

| Task | Acceptance |
|------|------------|
| Public HTTPS URL | Game loads without `file://` |
| Cold-load metrics | Record raw MiB, gzip estimate, time-to-interactive (manual + script) |
| PWA / fullscreen | Install prompt or fullscreen path tested on Android Chrome |

**Repo today:** Export to `build/web/` + `tools/validate_web_export.py`. **Missing:** hosted URL (e.g. GitHub Pages), load telemetry artifact, device capture.

### 2. Mobile browser stability

| Task | Acceptance |
|------|------------|
| Portrait + landscape | HUD relayout; no permanent viewport striping |
| Safe areas | Notch/home indicator do not cover joystick or attack cluster |
| Touch joystick | Drag-to-move; release on tab blur / visibility hidden |
| Camera gestures | Deferred to Gate 03 / Kein-Name slice unless blocking web play |
| Fullscreen / PWA | `display: standalone`, orientation policy documented |
| Back / tab switch | No stuck `Input` actions; game resumes after focus |
| Combat | No freeze after basic attack / skill on web |

**Repo today:** `BrambleOrientationService`, production HUD stick (native + web events on `main`). **Missing:** web focus/back handling, safe-area margins, real Android browser QA evidence.

### 3. Startup size (&lt; 35 MiB gzip)

| Task | Acceptance |
|------|------------|
| Budget | `validate_web_export.py --max-transfer-mib 35` PASS |
| Runtime icon atlas | Small explicit atlas; stop pulling full icon families via exclude hacks |
| Stream later zones | Raid/field extras not in startup PCK (manifest or second pack) |

**Repo today:** ~**41.5 MiB** gzip estimate (Gate 01 ~41.6). **Fails** 35 MiB gate.

### 4. Kein-Name combat (after Gate 02 PASS)

Tap target, auto-attack until dead/out of range/cancel, projectiles, free camera + zoom, separated world/camera/gameplay state.

**Not in Gate 02.**

### 5. Vertical slice (after combat port)

Village, field, quest giver, level/job, portal, Harvest Colossus raid map, return to village.

**Not in Gate 02.**

## Recommended order (locked)

1. **Web browser stable on real Android** (this gate)  
2. **Kein-Name combat port**  
3. **Village / field / raid connected**  
4. **Progression and classes**

## Evidence checklist (Gate 02 exit)

- [ ] URL documented in this file (production preview)  
- [ ] Validator PASS at 48 MiB (regression) and PASS at 35 MiB (target)  
- [ ] Screen recording: portrait + landscape, move + attack, tab away/back  
- [ ] Notes: device, browser, load time, memory (Chrome devtools or equivalent)  
- [ ] No open P0: HUD missing, stuck input, post-attack hang  

## Commands

```bash
mkdir -p build/web
godot --headless --path . --export-release "Web Mobile Gate" build/web/index.html
python3 tools/validate_web_export.py --max-transfer-mib 48
python3 tools/validate_web_export.py --max-transfer-mib 35
# Serve: python3 -m http.server 8080 --directory build/web
```

## Gate 03 preview

Kein-Name parity slice + runtime atlas completion + optional second-stage PCK for non-village content.
