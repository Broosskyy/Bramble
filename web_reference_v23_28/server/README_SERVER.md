# BRAMBLE V23.23 LAN / Party Server

Requires Node.js 18+ and no npm packages.

## Windows
Double-click `start_server.bat`.

## macOS / Linux
Run:
`./start_server.sh`

Then open:
`http://localhost:8787`

Other devices on the same network use:
`http://<IP-of-server-PC>:8787`

The server provides:
- accounts / saves
- live player presence
- role identity (user / mod / admin)
- parties up to 5 players
- map/range-aware shared EXP, Job-EXP and reputation
- shared farming rewards
- party reward inbox
- server-shared group raid
- server-shared event instance
- basic activity cooldown validation and shared boss HP

`server_data.json` is created automatically and persists state.

This is a prototype LAN backend, not hardened production infrastructure. Before public deployment:
use TLS, a database, password hashing, rate limiting, real auth/session expiry,
authoritative movement/combat validation, anti-cheat, transactional rewards and audit logs.
