# GitHub Delivery Workflow

**Project:** `BRAMBLE_GAME/`  
**Repository:** https://github.com/Broosskyy/Bramble.git  
**Branch:** `main`  
**Remote:** `origin`

---

## Overview

After every successfully completed BRAMBLE task, the canonical project is:

1. Runtime-validated in Godot 4.7.2  
2. Captured to `artifacts/live/`  
3. Documented in `artifacts/live/LIVE_BUILD.md`  
4. Committed with a conventional message  
5. Pushed to `origin/main` (no force push)

---

## Git Setup

```powershell
cd BRAMBLE_NEW/BRAMBLE_GAME
git init -b main
git remote add origin https://github.com/Broosskyy/Bramble.git
git fetch origin
# If remote has README only: merge with --allow-unrelated-histories
git pull origin main --allow-unrelated-histories --no-edit
```

**Never:** `git push --force`, destructive `git reset --hard` against unknown state.

If local and remote histories diverge incompatibly: **stop and report**.

---

## .gitignore Policy

Ignored:

- `.godot/`, `.import/` (cache)
- OS/IDE temp, logs, secrets, `.env*`
- `_asset_work/`, temp extraction dirs

**Versioned:**

- `assets/` (production assets)
- `docs/`
- `artifacts/live/`
- `artifacts/m02/`, `artifacts/m02_1/`, `artifacts/m02_2/`, etc.
- Sidecar `*.import` files next to assets (Godot import metadata)

---

## Runtime QA

| Step | Command |
|------|---------|
| Smoke test | `Godot --path BRAMBLE_GAME res://scenes/main.tscn --smoke-test` |
| Live capture | `Godot --path BRAMBLE_GAME res://scenes/main.tscn --live-capture gameplay` |

Smoke test verifies:

- No parse errors  
- Main scene loads  
- `VisualMasterWorld` visible  

---

## Live Artifact Paths

| File | Purpose |
|------|---------|
| `artifacts/live/latest_landscape.png` | 1920×1080 village focus |
| `artifacts/live/latest_portrait.png` | 1080×1920 village focus |
| `artifacts/live/latest_gameplay.png` | 1920×1080 combat focus (when relevant) |
| `artifacts/live/LIVE_BUILD.md` | Build metadata |

Milestone folders (`artifacts/m02_2/`, etc.) are preserved separately.

---

## Delivery Script

`tools/bramble_delivery.py`

```powershell
py -3 tools/bramble_delivery.py `
  --milestone m02.2 `
  --message "feat(m02.2): visual production pass and delivery workflow"
```

Options:

| Flag | Effect |
|------|--------|
| `--capture-only` | Runtime + screenshots only |
| `--no-push` | Commit locally, skip push |
| `--skip-gameplay` | Skip gameplay screenshot |

**Blocks delivery on:**

- Godot parse error  
- Smoke test failure  
- Missing/empty PNG captures  
- Merge conflict  
- Push failure  

---

## Commit Convention

```
feat(m03): playable combat loop
fix(world): terrain tile bleed
docs(m02.2): visual production report
chore(workflow): delivery script
```

---

## Failure Rules

If any step fails, report:

```
IMPLEMENTATION = PASS/PARTIAL/FAIL
RUNTIME = PASS/FAIL
CAPTURE = PASS/FAIL
COMMIT = PASS/FAIL
PUSH = PASS/FAIL
```

Do **not** claim task completion. Preserve local work.

---

## Post-Task Rule (Cursor)

See `CURSOR_RULES.md` — every completed task ends with validation, capture, commit, push.

When `local HEAD == origin/main HEAD`:

**GITHUB_DELIVERY_WORKFLOW = ACTIVE**
