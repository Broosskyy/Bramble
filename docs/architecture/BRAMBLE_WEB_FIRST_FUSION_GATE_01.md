# Bramble Web-First Fusion Gate 01

Date: 2026-10-05

Engine: Godot 4.7.2 stable

Source baseline: `Broosskyy/Bramble` `main` at `319a44c`

## Decision

Bramble/Godot becomes the shared runtime foundation for browser, Android, iOS and desktop. The current Kein-Name browser game remains a gameplay and presentation donor while features are migrated behind explicit parity gates; its renderer and simulation are not copied wholesale into Godot.

This is the lowest-risk route to one gameplay core and multiple distributions:

- Web remains the first public entry point.
- Android/iOS can use native Godot exports after the web slice is stable.
- Desktop can use the same project and authoritative world model.
- Camera/input presentation may vary per platform; gameplay state does not.
- No client camera state becomes shared or server-authoritative state.

## Implemented in Gate 01

- Added a single-threaded `Web Mobile Gate` export preset with PWA output.
- Added a `web_mobile_gate` feature flag.
- Removed build evidence, source references, labs and inactive content families from the startup package.
- Removed the hidden legacy gallery from the web startup path while retaining it for native development.
- Converted runtime loot visuals to the current production item assets.
- Removed the legacy signpost layer underneath the production portal.
- Made missing optional assets fail safely instead of producing a blank/broken runtime path.
- Fixed Godot 4.7.2 type inference errors in production HUD pointer handling.
- Fixed headless smoke tests waiting forever on `RenderingServer.frame_post_draw`.
- Added a deterministic web-artifact validator with a 48 MiB compressed-transfer gate.

## Evidence

| Check | Result |
|---|---:|
| Godot import / script parse | PASS |
| Headless production-world smoke | PASS |
| Exported `index.pck` production-world smoke | PASS |
| Release Web export | PASS |
| Required HTML/JS/WASM/PCK artifacts | PASS |
| HTTP startup artifact smoke | PASS |
| WASM MIME type | `application/wasm` |
| Initial raw export | 106.0 MiB |
| Gate 01 raw export | 70.24 MiB |
| Initial estimated gzip transfer | 76.3 MiB |
| Gate 01 estimated gzip transfer | 41.62 MiB |
| Startup PCK | 31.99 MiB |
| WASM | 37.68 MiB raw / 9.59 MiB gzip |

The compressed startup estimate is approximately 45% smaller than the first valid export. It is acceptable for an architecture gate, but not the final target for frictionless mobile onboarding.

## Web export command

```bash
godot --headless --path . --export-release "Web Mobile Gate" build/web/index.html
python3 tools/validate_web_export.py
```

Serve the output through HTTP(S); do not open the HTML directly from the filesystem.

## Content policy for the startup package

The web gate includes the playable production village slice, directional player, Moorling combat, NPCs, production HUD, loot, terrain and portal. It excludes legacy galleries, asset source sheets, reference art, inactive monsters, labs and future-map content.

Some dynamic inventory and skill icons currently fall back to the generic runtime icon because their full source families are deliberately excluded from the startup gate. Gate 02 must create a small explicit runtime atlas rather than re-adding entire source directories.

## Fusion sequence

1. **Web Gate 01 (this change):** reproducible Godot Web export, deterministic smoke, startup budget.
2. **Web Gate 02:** browser runtime capture, mobile input/resize/orientation QA, runtime icon atlas, cold-load telemetry.
3. **Kein-Name parity slice:** port target-and-auto-attack, camera freedoms, projectile causality and mobile fullscreen behavior into Godot services.
4. **Harvest Colossus raid:** implement the boss as a separate data-driven map/encounter inside Bramble, not as a replacement main scene.
5. **NosTale-like original RPG loop:** town, field maps, portals, quests, character/job levels, class selection and specialist-card progression using original names, balance, art and implementation.
6. **Shared online authority:** identity, persistence, inventory, combat validation and party/session services become deployable server contracts.
7. **Native packaging:** Android first, then iOS/desktop, all consuming the same gameplay core and account/world state.

## Gate 02 acceptance targets

- Real Chromium/Safari/Android browser capture, not an offline reconstruction.
- Portrait and landscape resize without HUD loss.
- Touch movement, target selection, attack loop and camera gestures do not conflict.
- Fullscreen/PWA safe-area behavior is verified on physical Android.
- Initial compressed transfer target: below 35 MiB, with optional content streamed after entry.
- No gameplay-affecting difference between Web and native quality profiles.

## Known limitations

- Automated visual browser capture is pending. The available external browser was not authorized to open the private local build; no screenshot was faked.
- Physical Android Web validation is pending.
- iOS Safari validation is pending.
- The current Godot slice is 2.5D; Harvest Colossus hybrid-3D presentation remains a later, isolated encounter decision.
- The web export still uses an all-resources preset with exclusions. A manifest-driven startup atlas is required before public release.
