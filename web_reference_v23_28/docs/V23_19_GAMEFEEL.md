# V23.19 Gamefeel

Portable concepts for the later Godot client:

- `screenShake`: presentation-only camera impulse.
- `hitStop`: local visual simulation pause; not network authority.
- `combatUntil`: presentation state used only to change HUD emphasis.
- rarity beams: presentation derived from item rarity.
- contextual world prompts: presentation derived from already-resolved interaction candidates.
- quest collapse: local UI preference.
- area toast: map transition feedback.

These systems intentionally avoid becoming gameplay authority so they can migrate cleanly.
