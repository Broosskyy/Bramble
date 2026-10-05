# Android Debug-APK herunterladen

Die APK liegt **nicht** im GitHub-Dateibaum (`.gitignore`: `build/`, `*.apk`).

## Automatischer Build (empfohlen)

1. Öffne **Actions** im Repo: https://github.com/Broosskyy/Bramble/actions  
2. Workflow **„Android Debug APK“** auswählen  
3. **Run workflow** → Branch `main` → Run  
4. Nach grünem Lauf: unten **Artifacts** → **`bramble-android-debug-apk`** herunterladen  
5. Datei entpacken oder direkt installieren: `bramble-android-debug.apk`

Bei Push auf `main` (Scripts/Szenen/Assets) startet der Workflow auch automatisch.

## Lokal (Godot)

Export-Preset **Android** → Ziel: `build/android/bramble-android-debug.apk`
