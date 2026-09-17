# BRAMBLE Game Feel and Visible Progression

Status: product acceptance contract established by M04.26

BRAMBLE must feel like one coherent game rather than a collection of
individually functional systems. Runtime play and screenshots outrank code
claims when judging presentation.

## Locked principles

1. Features must feel connected through shared world, character, combat,
   progression, and feedback language.
2. Progression must be visible in the world.
3. Progression must be mechanically noticeable in what the player can
   comfortably defeat, survive, reach, or unlock.
4. Equipped wearable/carried items change the world character's appearance.
5. SPs later create major visual and gameplay transformations, not recolors.
6. Pets, partners, and fairies later visibly accompany and communicate
   progression.
7. Maps are designed around routes, decisions, interaction, combat, recovery,
   and landmarks rather than asset count.
8. Player recognition has priority over decoration.
9. Combat requires enough open ground to read self, target, attack direction,
   and danger.
10. Reward feedback scales with reward importance.
11. New power changes which enemies or areas are comfortable and accessible.
12. UI explains progression but never substitutes for character/world
   feedback.
13. Visual quality and gameplay readability are acceptance gates.
14. Every milestone asks: **Does this actually feel better to play?**

## Spatial gameplay rhythm

A small BRAMBLE area should support a readable loop:

`spawn → orient → move → notice landmark → interact → follow route → encounter
→ target → attack → receive feedback → continue`

Low-density space belongs around spawn, traversal, and combat movement.
Medium-density composition belongs around building approaches and NPC
interaction. Higher-density decoration frames the perimeter. Buildings and
vegetation shape routes without consuming them.

## Character priority

- The player should be identifiable within approximately one second.
- Visible ground around the feet establishes position and movement options.
- Scale is calibrated across camera, building, NPC, monster, and vegetation;
  player size is not increased automatically.
- Contact shadow, stable ground pivot, spatial collision, and camera-relative
  direction must agree.
- Portrait and landscape retain the same world state and geometry.

## Visible equipment progression

An unequipped/equipped comparison must be obvious without opening inventory.
Helmet, armor, and weapon should read as one intentional tier. Direction,
movement, and combat cannot detach equipment from the body.

Visual progression later extends to:

- equipment tiers, rarity, and upgrades
- SP appearance and VFX
- pets, partners, fairies, and mounts
- prestige and endgame presentation

Mechanical progression must accompany presentation through stats, skills,
survivability, access, or combat options. This milestone validates visual
difference only; it does not claim a new authoritative power tier.

## Combat feel

Required readable information:

- self
- current target
- attack direction
- hit confirmation
- immediate danger
- route out of combat

Camera freedom is subordinate to this information. Target rings, hit flashes,
damage values, animation/VFX, and sound should reinforce the same event.
Decoration may frame a combat pocket but cannot occupy its movement space.

## Interaction feel

NPCs need clear approach space, stable grounding, readable identity, an
unambiguous interaction prompt, and dialogue that does not hide the entire
world. The player and NPC silhouettes must not merge.

## Camera feel

- Player-follow only; no free flight or roll.
- Bounded yaw, pitch, and zoom.
- The supported yaw range is determined by asset quality.
- Landscape and portrait may change framing and anchor bias.
- Mobile camera gestures use safe world regions after movement, targeting,
  and skill controls consume their touches.
- Camera orientation is local presentation state and never authority data.

## Feedback scale

- Routine hit: immediate world flash/VFX and compact damage feedback.
- Equipment upgrade: visible character change plus concise UI confirmation.
- Quest milestone: world/UI response larger than a routine pickup.
- Level, SP, rare item, or major unlock: increasingly distinctive audiovisual
  treatment.

## Milestone acceptance questions

Before accepting future work, verify:

- Can a new player identify their character and next route?
- Is interaction separated from decoration?
- Does combat preserve breathing room?
- Does the reward visibly and mechanically matter?
- Do landscape and portrait communicate the same state?
- Does camera freedom improve occupancy without exposing asset failures?
- Does this make BRAMBLE feel more like a real, cohesive game?
