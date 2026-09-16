# V23.17.1 Startup Hotfix

Fixed initialization order:

BAD:
1. define new enemy types
2. mutate MAP_ACTIVITY
3. declare MAP_ACTIVITY

GOOD:
1. define new enemy types
2. declare MAP_ACTIVITY
3. extend its pools

Static checks:
- JavaScript syntax: PASS
- referenced UI IDs: PASS
- initialization ordering: PASS
