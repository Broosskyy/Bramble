# BRAMBLE

Shared Godot 4.7.2 game core for browser and Android. Kein-Name gameplay is
being migrated into this project in narrow, verified steps.

```bash
python3 tools/build_game.py --target all
```

Set `GODOT_BIN`, `JAVA_HOME` and `ANDROID_HOME` or configure the SDK paths in
Godot. [Build setup, outputs and signing](docs/workflow/BUILD_WEB_ANDROID.md).

GitHub Actions **Web + Android Builds** automatically produces a Web ZIP and
signed test APK after relevant pushes to `main`, and can be run manually.
