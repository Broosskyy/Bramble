# Bramble Web-First Fusion Gate 02

## Goal

Gate 02 stabilizes the Godot runtime as a browser-first mobile client before
additional Kein-Name combat systems are ported. The gate focuses on viewport
changes, device safe areas, fullscreen, portrait/landscape HUD continuity, and
repeatable web export validation.

## Runtime contract

- Godot remains the shared gameplay/runtime core for Web, Android, iOS, and
  desktop exports.
- The Web export remains single-threaded for broad mobile-browser compatibility.
- The browser canvas follows the available viewport and supports portrait and
  landscape without reloading gameplay.
- Fullscreen is user initiated. The game never forces fullscreen on startup.
- Camera and simulation state remain independent of viewport and HUD layout.

## Changes

### Web platform service

`BrambleWebPlatformService` owns presentation-only browser/window behavior:

- reports logical viewport metrics;
- converts physical display safe areas into logical canvas insets;
- exposes explicit fullscreen enter/exit through one user-facing toggle;
- settles resize bursts for two frames before publishing final metrics;
- detects external fullscreen exits and refreshes layout.

It does not own movement, combat, world coordinates, camera authority, or
network state.

### Orientation and resize

`BrambleOrientationService` now emits a layout refresh after every settled
viewport resize, even if the resize remains portrait or remains landscape.
This covers browser address-bar changes, fullscreen entry/exit, split-screen,
and desktop window resizing.

### HUD

The production combat HUD now:

- applies left/top/right/bottom safe-area insets;
- lays out again after viewport metrics settle;
- provides a compact `FS` / `EXIT` fullscreen control;
- keeps joystick, combat controls, navigation, minimap, and top panels inside
  the usable viewport;
- keeps fullscreen as a local presentation action.

The RPG overlay uses the same safe-area information and scales its shell to the
usable viewport.

### Web shell

The export injects a mobile viewport with `viewport-fit=cover`, disables page
scroll/overscroll, and gives the Godot canvas full-viewport touch behavior.

## Validation

Local static validation:

```bash
python3 tools/validate_web_mobile_source.py
```

Godot validation when the 4.7.2 editor and matching web templates are present:

```bash
godot --headless --path . --script tools/web_mobile_gate_test.gd
godot --headless --path . --export-release "Web Mobile Gate" build/web/index.html
python3 tools/validate_web_export.py --build-dir build/web --max-transfer-mib 48
```

`.github/workflows/web-mobile-gate.yml` performs the same source test,
GDScript test, release export, artifact audit, and uploads the playable web
artifact. It does not publish a public website.

## Acceptance status

- Source contract: implemented.
- Fullscreen control: implemented; real browser gesture validation required.
- Same-orientation resize relayout: implemented.
- Safe-area-aware HUD and RPG overlay: implemented.
- Deterministic Web export CI: implemented.
- Physical Android browser: pending.
- Physical iOS Safari/PWA: pending.
- Public preview deployment: intentionally not enabled until explicitly
  approved.

## Known browser risks

- iPhone Safari does not offer identical Fullscreen API behavior to desktop or
  Android browsers; installed PWA standalone mode remains the expected iOS
  full-screen path.
- Display cutout reporting depends on platform/browser support for the Godot
  display safe-area API. The fallback is zero inset plus the normal HUD margin.
- Browser UI expansion/collapse can produce several intermediate resize events;
  the two-frame settle prevents most visible layout thrashing, but physical
  device recordings are still required.

## Next gate

After real browser/device verification, port the first narrow gameplay slice
from Kein-Name into the shared Godot core:

1. tap/select target;
2. press attack to start sticky auto-attack;
3. stop when target dies, is invalid, leaves range, or the player cancels;
4. retain server-authoritative-compatible combat state;
5. add only the minimum quest/monster loop needed to validate the NosTale-like
   browser-first direction.
