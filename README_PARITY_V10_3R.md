# BRAMBLE Godot 4.7.2 — V10.3R Recovery / Parser Hardening

Recovered from the last complete V10 Web Import + Online Hardening archive after the previous V10.3 attachment expired.

This recovery preserves the full V10 project/content baseline and applies the verified Godot 4.7.2 parser hardening for dynamic Variant-returning expressions (JSON/content loading and selected Dictionary-derived values).

Distribution is split into:
1. CORE — project, scripts, scenes, data and Web V23.28 migration/reference.
2. RUNTIME_ASSETS — runtime asset directories, including the Work-Chat master pool.
3. SOURCE_ASSET_ARCHIVES — source kits/archives retained for production provenance; not required for ordinary runtime testing.

Extract CORE first, then merge RUNTIME_ASSETS into the same project folder. SOURCE_ASSET_ARCHIVES is optional for runtime testing.

Static QA only: no Godot executable was available in the build environment, so this package is not claimed as runtime-tested.
