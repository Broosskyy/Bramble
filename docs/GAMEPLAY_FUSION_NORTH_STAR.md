# Gameplay Fusion North Star

## Product identity

The fused game is one product, not two modes and not a 50/50 technical merge.

- **Kein Name defines the gameplay DNA:** movement feel, camera feel, fast direct combat, target-to-attack flow, hit feedback, damage numbers, loot intensity, fast progression feedback and moment-to-moment pacing.
- **Bramble defines the RPG/world depth:** authored 2.5D world, regions, quests, equipment, builds, skills, crafting, dungeons, raids/bosses, economy, social systems, online/server authority and long-term progression.
- **Direction:** a modern, original 2D/2.5D online action RPG inspired by the accessibility and structural strengths of classic games such as NosTale, while remaining its own IP, world, characters, systems, art direction and content.

## Non-negotiable feel rules

1. Mobile movement must be immediate, reliable and true 360-degree analogue input.
2. Desktop movement must remain available for development and browser play.
3. The player must never leave authored playable bounds or become lost outside the camera/world.
4. Combat must stay fast and readable; RPG depth may add choices but must not make the core loop sluggish.
5. Web and Android use the same Godot gameplay codebase and should feel equivalent.
6. Existing Bramble systems are retained when they deepen the fused game; they do not override the Kein-Name moment-to-moment feel.

## Fusion implementation order

1. Player input + camera + world-bound safety.
2. Kein-Name target / approach / auto-attack combat loop.
3. Hit, damage-number, death, XP and loot feedback pass.
4. Bramble equipment/build/skill/quest depth attached to that loop.
5. Dungeon/raid, social, account/save, multiplayer and server-authoritative expansion.

## Current milestone

**Fusion Phase 2 — Kein Name Combat Core**

Implemented flow target: tap/click enemy -> persistent target lock -> automatic approach -> face target -> repeated basic attacks in range -> hit/damage feedback -> defeat -> XP/loot through the existing Bramble RPG/runtime services.

Phase 1 remains a hard gate: touch joystick must move correctly in every direction including diagonals, analogue magnitude is preserved, keyboard controls still work, the player stays inside the playable world, and Web/Android use the same behavior.

Phase 2 exit criteria: forgiving mobile target selection, no target loss while approaching, manual movement can override auto movement, no one-hit attack lock, live target HP state, visible defeat feedback, and the loop works through the existing online-ready combat/reward architecture rather than a parallel prototype system.
