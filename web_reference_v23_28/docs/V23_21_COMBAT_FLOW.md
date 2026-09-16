# V23.21 Combat Flow

Enemy melee flow:
1. aggro
2. approach
3. windup
4. visible warning telegraph
5. strike if still in range
6. cooldown

Dash currently grants 360 ms of prototype local i-frames.

For a future online/Godot build, windup start and strike resolution should become
server-authoritative. Telegraphs, cooldown rings and quest guides remain presentation.
