# Android Debug-APK herunterladen

Die APK liegt **nicht** im GitHub-Dateibaum (`.gitignore`: `build/`, `*.apk`).

## Release (direkt)

https://github.com/Broosskyy/Bramble/releases — neuestes Tag **`android-debug-*`** → Asset **`bramble-android-debug.apk`**.

## Automatischer Build (Actions)

1. **Actions:** https://github.com/Broosskyy/Bramble/actions  
2. Workflow **„Android Debug APK“** → **Run workflow** (Branch `main`)  
3. Artifacts → **`bramble-android-debug-apk`**

## Installation schlägt fehl („App nicht installiert“)

Häufigste Ursache: **Eine ältere BRAMBLE GAME / `com.broosskyy.bramble` ist noch installiert**, signiert mit einem **anderen** Debug-Schlüssel (z. B. Godot auf dem Handy vs. GitHub-Build).

**So beheben:**

1. **Einstellungen → Apps → BRAMBLE GAME** (oder Godot-Testinstall) → **Deinstallieren**  
2. Optional: alte `bramble-android-debug*.apk` aus Downloads löschen, APK **neu** vom Release laden  
3. APK erneut installieren (Unbekannte Apps / Dateien erlauben)

Ab Version **0.1.1 (code 2)** nutzen alle Builds denselben Projekt-Debug-Keystore (`android/bramble-debug.keystore`), damit Updates ohne Deinstall möglich sind — **einmal** deinstallieren reicht, wenn vorher eine fremde Signatur auf dem Gerät war.

## Lokal (Godot)

Export-Preset **Android** → `build/android/bramble-android-debug.apk` (Keystore liegt im Repo unter `res://android/bramble-debug.keystore`).
