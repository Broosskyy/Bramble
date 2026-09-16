# V23.23 Staff / Party / Raid / Event

Staff identity:
- ADMIN: gold A seal
- MOD: blue M seal
- world badge + HUD + chat + party roster + minimap

Party:
- 5 players
- map/range-aware progression sharing
- shared farm rewards
- live presence and HP
- group bonus based on active party size

Group activities:
- server shared raid/event boss state
- contribution tracking
- action cooldown validation
- shared result/reward delivery

Production migration:
All reward, role, activity and party authority should remain server-side.
Godot client should only render these states and submit input/action intents.
