# CURSOR_RULES — BRAMBLE

Project root: `BRAMBLE_NEW/BRAMBLE_GAME/`  
Repository: https://github.com/Broosskyy/Bramble.git  
Branch: `main`  
Remote: `origin`

## Permanent Delivery Rule

Every completed BRAMBLE implementation task must end with runtime validation,
fresh live screenshots, commit and push to origin/main. Never force push.
If validation, capture, authentication, merge or push fails, stop and report
the exact failure.

## Post-Task Checklist (mandatory)

A. Review changes (`git diff`, `git status`)  
B. Run relevant tests  
C. Start Godot 4.7.2 runtime  
D. Capture current live state to `artifacts/live/`  
E. Update `artifacts/live/latest_landscape.png`  
F. Update `artifacts/live/latest_portrait.png`  
G. Update `artifacts/live/latest_gameplay.png` when combat/gameplay touched  
H. Update `artifacts/live/LIVE_BUILD.md`  
I. Verify git status  
J. Commit with conventional message  
K. Push to `origin/main`  
L. Verify remote SHA matches local HEAD  

## Delivery Command

On Windows use the Python launcher:

```powershell
py -3 tools/bramble_delivery.py --milestone mXX --message "feat(mXX): description"
```

Capture only (no commit):

```powershell
py -3 tools/bramble_delivery.py --capture-only
```

## Commit Convention

- `feat(m03): playable combat loop`
- `fix(world): terrain seam overlap`
- `docs(workflow): update delivery guide`
- `chore(assets): catalog sync`

No vague messages (`update`, `changes`, `fix`).

## Failure Reporting

Report exact status:

- IMPLEMENTATION = PASS / PARTIAL / FAIL  
- RUNTIME = PASS / FAIL  
- CAPTURE = PASS / FAIL  
- COMMIT = PASS / FAIL  
- PUSH = PASS / FAIL  

Do not claim completion if any required step failed.

## Scope Rules

- Work only in `BRAMBLE_NEW/BRAMBLE_GAME/` for canonical game code  
- Do not force push  
- Do not delete local working changes because of GitHub auth failures  
- Production assets under `assets/` must remain versioned  

## Continuous Visual QA (M04+)

`VISUAL_FOUNDATION_LOCKED` does not mean final visual quality. Every gameplay milestone must:

- visually polish the systems it touches
- avoid new prototype/debug UI in production paths
- preserve Player/Target readability during combat
- fix obvious local visual regressions encountered in touched areas
- validate Landscape and Portrait layouts
- generate fresh live screenshots for touched systems

Do not reopen locked foundations for ordinary polish. Future maps should mix dense decorative areas with open movement/combat/interaction spaces instead of covering the entire playable area with decorative assets.

See also: `docs/workflow/GITHUB_DELIVERY_WORKFLOW.md`
