# One project, Web and Android builds

Godot **4.7.2 stable** is pinned for both targets. Both export presets package
the same production scene (`res://scenes/main.tscn`) and the same startup asset
scope. The historical `web_mobile_gate` feature marks this small distribution
package on both targets; it does not make Android behave as a browser.

## Build from your computer

Install Godot 4.7.2 and its matching export templates. For Android, install
OpenJDK 17 and Android SDK packages `platform-tools`, `platforms;android-36`,
and `build-tools;36.0.0`. The APK preset uses prebuilt templates, without a
Gradle project or source compilation.

Use Python 3.11 or newer. The pinned 4.7.2 Android template targets SDK 36
and requires Android 7.0 (API 24) or newer. The SDK values follow the actual
4.7.2 exporter and template, rather than older SDK 35 documentation examples.
The project includes a simple vector build icon, which can be replaced with
the final approved app branding later.

From the repository root:

```bash
python3 tools/build_game.py --target all --godot /path/to/godot \
  --android-sdk /path/to/Android/Sdk --java-sdk /path/to/jdk-17
```

On Windows use `py -3` instead of `python3`, and supply the Windows executable
and SDK paths. Close the Godot editor before CLI builds. You can also configure
Java/Android SDK paths in the editor and omit the SDK arguments, or set
`GODOT_BIN`, `JAVA_HOME`, and `ANDROID_HOME` in your environment.

Individual targets:

```bash
python3 tools/build_game.py --target web
python3 tools/build_game.py --target android
```

The same presets remain selectable through Godot's Project → Export menu.

## Outputs and checks

| Output | Purpose |
|---|---|
| `build/web/index.html` and sibling files | HTTP-hosted browser game |
| `build/bramble-web.zip` | Complete Web export, extract before hosting |
| `build/android/Bramble.apk` | Signed Android test APK, ARMv7 and ARM64 |
| `build/build-manifest.json` | Source commit, local changes, sizes and SHA-256 |
| `build/logs/` | Import, smoke, export and artifact diagnostics |

The command rejects version mismatches, different target content filters,
script/import errors, failed smoke tests, invalid exported Web data, corrupt
APKs, missing Android libraries, incorrect package identity, and invalid APK
signatures. Its success report records real-device validation as pending.

Serve `build/web` over HTTP(S), never by opening `index.html` as a local file.
For a local check: `python3 -m http.server 8000 --directory build/web`.
The single-threaded Web export does not require SharedArrayBuffer isolation.

## GitHub builds

**Actions → Web + Android Builds → Run workflow** builds both targets.
Pushes to `main` and relevant pull requests build them automatically. Web and
Android are independent matrix jobs, so a failed APK does not cancel the Web
job. Download the corresponding `bramble-web-<commit>` or
`bramble-android-<commit>` artifact after a successful run.

The workflow also captures the native production scene in portrait and
landscape. These are native runtime captures, not browser or physical-device
evidence. The workflow creates downloadable artifacts; it does not publish a
website or upload to an app store.

## Test signing and future store release

The build tool creates a local debug key outside the repository and reuses it.
GitHub caches its own test key for subsequent APKs. Keep the same key when
installing updates: a different signing key requires uninstalling the old test
app. Cache eviction or switching between local/CI builds may change the key.
Never use this debug key for a production release.

APK output is for direct Android testing. A Play Store release needs a separate
release key, application versioning and an AAB/Gradle export. No production
signing material is stored in this repository.

## Fusion status

This milestone establishes reproducible distribution of the existing Bramble
production slice. It does not claim completion of the Kein-Name gameplay port.
The target/explicit auto-attack port, 3D scene integration, projectiles and
Harvest Colossus encounter remain separate gameplay milestones. Browser and
physical Android tests remain required before release approval.

Reference: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html

Pinned exporter defaults: https://github.com/godotengine/godot/blob/4.7.2-stable/platform/android/export/export_plugin.cpp
