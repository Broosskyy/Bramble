# BRAMBLE LIVE BUILD

Milestone: shared Web + Android build pipeline
Date: 2026-10-06
Godot: 4.7.2.stable.official.ed1daf0bf
Baseline: abf19672a315708378be3f6ecb52ac75ed3c9f1b
Source: accompanying build-pipeline commit; exact build identity is emitted in build/build-manifest.json
Main Scene: res://scenes/main.tscn

- Source mobile contract: PASS
- Godot import / script parse: PASS
- GDScript mobile gate: PASS
- Main scene headless smoke: PASS
- Release Web export and exported-PCK smoke: PASS
- Web artifact/transfer audit: PASS (approximately 41.5 MiB estimated gzip)
- Android debug APK export: PASS (ARM64 + ARMv7, approximately 87 MiB)
- APK ZIP, package, exported launcher alias and v2/v3 signatures: PASS
- Native runtime captures: PASS (fresh files listed below)

| Capture | Resolution |
|---|---|
| artifacts/live/latest_landscape.png | 1920 × 1080 |
| artifacts/live/latest_portrait.png | 1080 × 1920 |
| artifacts/live/latest_gameplay.png | 1920 × 1080 |

These images are actual Godot native-runtime captures under a software X11
display. They do not constitute browser rendering or physical Android evidence.
No gameplay migration or 3D scene promotion is claimed in this milestone.

Remaining: real-browser input/fullscreen validation, physical Android install
and performance, Kein-Name target/auto-attack migration, and separate 3D/raid
integration. Older M04.31B spatial evidence remains in its milestone folders.
