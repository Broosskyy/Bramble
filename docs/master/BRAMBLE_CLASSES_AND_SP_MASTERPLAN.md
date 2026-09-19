# BRAMBLE Classes and Mantle/SP Masterplan

Status: locked product/content contract. Canon: level cap 60; four classes; eight Mantles (SPs); region bands R01 1–12, R02 13–24, R03 25–36, R04 37–48, R05 49–60.

## Rules shared by every class

- A class is permanent identity; a Mantle is an earned combat form. Neither is a paid power purchase.
- Base class choice occurs after a short common tutorial. Respec changes allocated nodes, not class. One free build preset is always available; additional presets are convenience only.
- Final stats are server-authoritative. Clients submit movement, target and skill intents; the server validates form, weapon, cost, cooldown, range, line of sight and target state.
- Base kit: basic attack, four active skills, one passive and dodge. Launch ships all four classes and both Mantles per class; no launch Mantle may be deferred while still counted as launch content.
- Player and Mantle presentation uses eight authored directions. Every state records pivot, sockets, depth, frame rate, loop/fallback/mirror policy, VFX/audio anchors and provenance. A Mantle is a replacement visual set, never a recolor.
- Mobile categories: `TAP` instant/target, `HOLD_AIM` drag-release, `PLACED` ground reticle, `CHANNEL` maintained button, `TOGGLE` persistent mode. All telegraphs remain legible in portrait and landscape.

## Skill production schema

Every row is a production record: stable ID; icon brief; authored animation; weapon requirement; cast model; projectile; VFX; impact; enemy telegraph; status; audio; mobile input. Icons require 256×256 source and 128/64/48 runtime sizes. Animations require eight-direction player/Mantle keyposes for anticipation, contact/release and recovery; locomotion-compatible skills may share approved base motion but never fake weapon handling.

## CLS_01 — Briar Vanguard

Role: melee protector/bruiser. Fantasy: a hedge-knight who turns pain into shelter. Primary weapons: sword, mace or spear; secondary/offhand: shield. Resource: 100 Resolve, gained by guarding, taking controlled damage and protecting allies. Stats favor vitality, defense and strength. Strengths: control, mitigation, reliable frontline. Limits: short reach, telegraphed mobility, lower burst. Party contribution: guard aura, interrupts, enemy grouping. Solo loop: mark → brace → counter → spend Resolve. PvP counterplay: flank, disengage during brace, purge roots. Visual silhouette: broad shield, thorned armor, planted stance. Launch: complete base kit, Thorn Bastion and Sunsteel Duelist. Post-launch: optional mastery nodes.

| Skill ID | Skill | Production record |
|---|---|---|
| SK_C01_01 | Hedgecut | Icon crossed thorn blade; 3-beat weapon swing; melee weapon; instant cone; no projectile; green edge arc; hit-stop/sparks; 0.25s arc tell; none; steel/branch hit; TAP |
| SK_C01_02 | Bramble Rush | Icon shield through vines; lean/sprint/slam; shield; aimed dash; no projectile; leaf trail; knock impact; lane + endpoint 0.45s; `KNOCKBACK`; shield boom; HOLD_AIM |
| SK_C01_03 | Root Challenge | Icon thorn crown; shield raise/shout; shield; instant radius; no projectile; root ring; taunt pulse; expanding 0.5s ring; `TAUNT` PvE / `WEAKEN` PvP; horned bark; TAP |
| SK_C01_04 | Verdant Guard | Icon leaf shield; brace loop/release; shield; channel 2s; no projectile; woven barrier; counter burst; persistent frontal wedge; `GUARD`,`COUNTER_READY`; wood creak/chime; CHANNEL |

Passive `SK_C01_P01 Unbroken Hedge`: blocking grants Resolve; repeated PvP blocks have diminishing Resolve. Class mastery branches: Bulwark (mitigation), Thorns (retaliation), Banner (party support).

## CLS_02 — Gale Strider

Role: ranged mobile damage/scout. Fantasy: a wind-runner who threads arrows through changing lanes. Weapons: bow primary; dagger secondary, quiver offhand. Resource: 3 Gust charges, one regenerating every 6s and accelerated by precision hits. Stats favor speed, physical attack and critical control. Strengths: mobility, range, pursuit. Limits: fragile, aim-dependent, punishable after dashes. Party: reveal, slow, priority-target pressure. Solo: kite → expose → precision shot → reposition. PvP counterplay: line-of-sight breaks, gap closes, bait Gust. Silhouette: long bow, streaming scarf, light asymmetrical layers. Launch: base kit, Tempest Ranger and Veilrunner.

| Skill ID | Skill | Production record |
|---|---|---|
| SK_C02_01 | Windshot | Icon spiral arrow; draw/release; bow; aimed line; arrow; pale wind ribbon; pinprick burst; 0.3s line glint; none; bow snap/whistle; HOLD_AIM |
| SK_C02_02 | Slipstream | Icon winged boot; directional dash; any class weapon; aimed dash; no projectile; air wake; landing puff; destination chevron; `HASTE` 2s; rush/cloth snap; HOLD_AIM |
| SK_C02_03 | Pinning Volley | Icon three descending arrows; high arc release; bow; placed AoE; 5 arrows; rain streaks; staggered impacts; 0.7s circle; `SLOW`; multi-thrum/ground ticks; PLACED |
| SK_C02_04 | Falcon Mark | Icon eye/fletching; point and nock; bow; target lock; fast sigil dart; sky-blue mark; reveal flash; target crest 0.4s; `REVEALED`,`VULNERABLE`; hawk cry/chime; TAP |

Passive `SK_C02_P01 Tailwind`: precision hits shorten Gust recovery; cannot trigger from periodic damage. Mastery: Marksman, Skirmisher, Pathfinder.

## CLS_03 — Ember Arcanist

Role: ranged spell damage/control. Fantasy: a hearth scholar balancing heat with tidal cooling. Weapons: staff primary; focus/orb offhand. Resource: Heat 0–100; fire raises it, cooling spells lower it; at 100, `OVERHEATED` blocks heat generators for 3s. Stats favor magic, resistance and cast speed. Strengths: AoE, elemental combos, burst windows. Limits: cast tells, heat management, vulnerable under pressure. Party: zone control, elemental exposure, burst. Solo: kindle → detonate → cool → reposition. PvP counterplay: interrupt casts, force overheat, leave zones. Silhouette: tall staff, glowing runes, compact robe hems. Launch: base kit, Cinder Sage and Tideshaper.

| Skill ID | Skill | Production record |
|---|---|---|
| SK_C03_01 | Ember Bolt | Icon coal comet; staff cast/recoil; staff/focus; target/aim; ember orb; orange tail; spark burst; 0.25s muzzle + line; `SCORCHED`; crackle/impact; TAP |
| SK_C03_02 | Hearth Ring | Icon fire circle; staff plant; staff; placed AoE; no projectile; low flame ring; pulse impacts; 0.8s circle; `BURNING`; ignition/loop; PLACED |
| SK_C03_03 | Flarestep | Icon fiery footprint; vanish/landing pose; any; aimed blink; no projectile; cinder trail; arrival flare; endpoint 0.4s; Heat +20; whoosh/pop; HOLD_AIM |
| SK_C03_04 | Quench Sigil | Icon blue rune over coal; two-hand seal; focus; instant self/radius; no projectile; steam spiral; cleanse puff; ally ring 0.35s; removes `BURNING`, Heat −35; hiss/bell; TAP |

Passive `SK_C03_P01 Tempered Flame`: alternating heat and cooling tags grants brief spell power; same-tag spam does not. Mastery: Combustion, Control, Tempering.

## CLS_04 — Bloom Warden

Role: healer/summoner-support. Fantasy: a traveling gardener who cultivates safe ground. Weapons: wand or crook primary; charm/totem offhand. Resource: 5 Seeds; damaging marked enemies and healing injured allies regrows one on internal cooldown. Stats favor magic, vitality and resistance. Strengths: sustain, cleansing, area support. Limits: setup time, lower burst, summons can be displaced. Party: healing, cleanse, buffs. Solo: seed ground → lure → bloom → harvest. PvP counterplay: force movement, pressure Warden, destroy ward sprouts. Silhouette: crook, petal mantle, seed satchel. Launch: base kit, Grovekeeper and Starcaller.

| Skill ID | Skill | Production record |
|---|---|---|
| SK_C04_01 | Mendbloom | Icon opening pink bud; wand sweep; wand/crook; target heal; pollen mote; petals; soft heal burst; ally-only halo; `REGEN`; harp pluck/bloom; TAP |
| SK_C04_02 | Seed Snare | Icon seed with roots; underhand cast; any focus; placed trap; seed arc; sprout trail; root clutch; 0.65s circle; `ROOT` then `SLOW`; seed rattle/snap; PLACED |
| SK_C04_03 | Canopy Ward | Icon leaf umbrella; crook plant/loop; crook/totem; placed field; no projectile; leaf dome; absorb shimmer; 0.7s circle; `WARD`; leaves/low hum; PLACED |
| SK_C04_04 | Pollen Wake | Icon golden swirl; traveling cast; wand/crook; channel trail; drifting motes; gold wake; periodic heal/hit; visible strip; `CLEANSE_MINOR`,`SLOW`; breath/chimes; CHANNEL |

Passive `SK_C04_P01 Patient Garden`: abilities on distinct targets grow Seed recovery; self-heal farming is capped. Mastery: Restoration, Wildgrowth, Symbiosis.

## Mantle system

### Lore and ownership

Mantles are memories of the First Canopy woven into wearable spirit-forms. A character resonates only with the two Mantles of their class. They alter skill kit, silhouette, animation, VFX and tactical role while preserving character name, level, inventory and social identity.

### Unlock, switching and progression

- First Mantle quest begins in late R02 and completes around levels 24–30: `SP_C01_01`, `SP_C02_01`, `SP_C03_01`, `SP_C04_01`.
- Second Mantle quest begins in R04 and completes around levels 42–50: `SP_C01_02`, `SP_C02_02`, `SP_C03_02`, `SP_C04_02`.
- Unlocks are deterministic quest achievements, account-catch-up eligible after one completion, and never random drops.
- Switch only out of combat, in hubs/sanctuaries or through a 6s uninterrupted field attunement. Dungeons allow switching at rest shrines; ranked PvP locks the declared Mantle for the match.
- Mantle rank 1–10 uses earned Resonance from level-appropriate quests, bosses, dungeons and PvP weekly equivalents. Ranks unlock three actives, one passive, two modifiers and cosmetics; rank cannot exceed the character’s region gate. Duplicate/grind protection grants targeted Resonance after three unrewarding eligible clears.
- Mantles inherit level and base stats; use class-compatible weapon families. Mantle-specific visible body, helmet treatment and spectral accents overlay equipped weapon/offhand. Armor stats remain active; competitive silhouettes cannot be hidden.
- One equipped fairy may resonate with the Mantle element for a utility interaction, never a mandatory damage multiplier. PvE coefficients and crowd control duration use separate PvP tuning tables.

## Mantle active skill production matrix

These records apply the same icon/animation/weapon/cast/projectile/VFX/impact/telegraph/status/audio/mobile schema as base skills. Every animation listed is authored for eight directions and includes anticipation, release/contact and recovery.

| Skill ID | Skill | Production record |
|---|---|---|
| SK_SP_C01_01_01 | Rampart Wall | Icon thorn wall; shield plant 12f; shield; placed frontal barrier; no projectile; woven briars; wall-rise impact; 0.8s rectangle; `BARRIER`; root/stone rise; PLACED |
| SK_SP_C01_01_02 | Briar Reprisal | Icon shield with returning thorns; block-to-sweep 10f; shield + one-hand weapon; instant cone; no projectile; green counter arc; heavy hit-stop; 0.35s cone; `STAGGER`; block clang/branch crack; TAP |
| SK_SP_C01_01_03 | Holdfast | Icon rooted boots; anchor/pull 12f; shield; channel radius; vine tethers; ground roots; pull landing; 0.7s ring + tethers; `PULL` PvE / `SLOW` PvP; deep root/strain; CHANNEL |
| SK_SP_C01_02_01 | Dawn Parry | Icon sun on crossed blade; parry/riposte 10f; sword; timed self; no projectile; gold guard flash; riposte spark; 0.2s blade glint; `PARRY_READY`; clear ring/steel snap; TAP |
| SK_SP_C01_02_02 | Gilded Lunge | Icon gold thrust; lunge 10f; sword; aimed dash line; no projectile; narrow sun trail; piercing flare; 0.45s lane; `MARKED`; blade rush/chime; HOLD_AIM |
| SK_SP_C01_02_03 | Noon Verdict | Icon noon sun blade; overhead finisher 14f; sword; target melee; no projectile; descending solar edge; radial burst; execute crest + 0.6s arc; `EXPOSED`; rising tone/impact; TAP |
| SK_SP_C02_01_01 | Stormneedle | Icon lightning arrow; charged draw 10f; bow; aimed line; lightning arrow; forked trail; electric pin; 0.35s line; `STORM_MARK`; taut bow/crack; HOLD_AIM |
| SK_SP_C02_01_02 | Crosswind Mine | Icon cyclone trap; underhand arrow plant 12f; bow; placed trap; arcing mine arrow; wind knot; burst lift; 0.65s circle; `SLOW`; whistle/gust pop; PLACED |
| SK_SP_C02_01_03 | Thunderflight | Icon winged thunderbolt; leap volley 14f; bow; aimed dash + shot; 3 arrows; storm wake; chain burst; destination + 3 rays 0.7s; consumes `STORM_MARK`; thunder roll/bow triplet; HOLD_AIM |
| SK_SP_C02_02_01 | Mistfold | Icon folded mist cloak; cloak-turn 12f; dagger/shortbow; instant self; no projectile; mist envelope; soft vanish; proximity ring persists; `CONCEALED`; breath/muffled chime; TAP |
| SK_SP_C02_02_02 | Afterimage Cut | Icon twin silhouettes; dash slash 12f; daggers or shortbow blade; aimed dash; no projectile; violet afterimage; cross-cut; 0.4s lane; `EXPOSED`; cloth rush/double slice; HOLD_AIM |
| SK_SP_C02_02_03 | Lanternbreak | Icon broken lantern eye; spin cast 14f; either legal weapon; instant radius; mist shards; dark pulse; reveal break; 0.65s ring; clears self `REVEALED`, applies `WEAKEN`; glass hush/low boom; TAP |
| SK_SP_C03_01_01 | Ashen Script | Icon ash glyph; staff inscription 12f; staff/focus; placed glyph; ember stylus mote; ash rune; armed pulse; 0.8s circle; `PRIMED`; charcoal scratch/ember; PLACED |
| SK_SP_C03_01_02 | Coalstar | Icon black-red comet; two-hand launch 12f; staff/focus; target/aim; coal orb; smoking tail; ember explosion; line + target spark 0.4s; `SCORCHED`; furnace draw/boom; HOLD_AIM |
| SK_SP_C03_01_03 | Grand Kindling | Icon three burning glyphs; staff raise 16f; staff; channel/detonate; glyph-to-caster sparks; linked flame lines; staged detonations; all glyphs pulse 1s; `BURNING`; rising crackle/triple report; CHANNEL |
| SK_SP_C03_02_01 | Rillbind | Icon water ribbon knot; orb weave 12f; staff/orb; aimed target; water ribbon; blue helix; binding splash; 0.45s line; `SLOW`; water draw/snap; HOLD_AIM |
| SK_SP_C03_02_02 | Returning Current | Icon returning wave arrow; sweep-turn 14f; staff/orb; boomerang line; crescent wave; water ribbon; outbound/return impacts; 0.6s double-arrow lane; `DISPLACED` PvE / `HINDERED` PvP; surf sweep/two hits; HOLD_AIM |
| SK_SP_C03_02_03 | Moonwave | Icon moon over crest; overhead wave cast 16f; staff; placed traveling front; wave mesh; silver-blue crest; lift splash; 0.9s broad lane; `KNOCKUP` PvE / brief `LIFT` PvP; deep surf/chime; PLACED |
| SK_SP_C04_01_01 | Shelterseed | Icon seed in leaf roof; seed plant 12f; crook/totem; placed summon; seed arc; sprout growth; cover pop; 0.75s circle; `SHELTER`; soil tap/leaf unfurl; PLACED |
| SK_SP_C04_01_02 | Elderbloom | Icon ancient open flower; nurture channel 14f; crook/totem; channel around sprouts; pollen links; growth rings; heal pulses; linked circles pulse 0.8s; `REGEN`; wood groan/bloom bells; CHANNEL |
| SK_SP_C04_01_03 | Harvest Mercy | Icon cut bloom with heart; crook reap 16f; crook; instant linked area; returning petal motes; green-gold return; burst heal; sprouts flash 0.6s; consumes sprouts, `HEAL`; soft cut/rising chord; TAP |
| SK_SP_C04_02_01 | Guiding Star | Icon star with path; wand point 12f; wand/charm; target ally/enemy; star mote; dotted trail; guiding flare; route/target crest 0.5s; `GUIDED`,`REVEALED`; glass note/travel chime; TAP |
| SK_SP_C04_02_02 | Comet Cradle | Icon comet in crescent; cradle sweep 14f; wand/charm; placed ally field; slow comet; astral bowl; shield landing; 0.8s circle + descent; `WARD`; distant whistle/warm chord; PLACED |
| SK_SP_C04_02_03 | Constellation | Icon connected six stars; sky-trace 18f; wand/charm; placed multi-point field; 6 star motes; linked lines; sequential pulses; points and hull preview 1s; `FORTIFIED` allies / `WEAKEN` enemies; six notes/final bloom; PLACED |

## Eight Mantle design and production contracts

### SP_C01_01 — Thorn Bastion

Role/fantasy: immovable protector clad in a living rampart. Element: verdant/earth. Weapon: shield plus sword/mace. Resource: 4 Rampart plates earned by intercepting hits. Loop: plant → intercept → retaliate. Actives: `SK_SP_C01_01_01 Rampart Wall` frontal ally barrier; `..._02 Briar Reprisal` cone counter; `..._03 Holdfast` anchor and pull nearby PvE enemies. Passive `SK_SP_C01_01_P01 Living Bulwark`: plates reduce next guarded hit. PvE: tank/peel; PvP: short barrier health and pull becomes slow. Counterplay: attack rear, wait out anchor, break wall. Equipment: shield silhouette mandatory; two-handed weapons disabled while active. Fairy synergy: Terra fairy widens first wall by 8%, utility only.

Exact production: 1 Mantle portrait; 4 skill icons; 8-direction body/helmet/shield layers; states idle 6f, move 8f, basic attack 8f, three skills 10/12/12f, hit 4f, defeat 8f, attune 12f; 3 cast/weapon socket tracks per direction; 3 telegraphs; 5 VFX families with low/high mobile tiers; 8 SFX + 1 short motif; barrier spatial mesh, collision and fade LOD; landscape/portrait/yaw/occlusion/PvP captures.

### SP_C01_02 — Sunsteel Duelist

Role/fantasy: solar challenger converting defense into precise offense. Element: solar/metal. Weapon: sword, no shield. Resource: 3 Tempo. Loop: parry → mark → lunge finisher. Skills: `SK_SP_C01_02_01 Dawn Parry`, `..._02 Gilded Lunge`, `..._03 Noon Verdict`; passive `SK_SP_C01_02_P01 Bright Edge`. PvE: off-tank/single-target; PvP: parry excludes periodic damage and Verdict has clear execute marker. Counterplay: feint, kite, deny mark. Equipment: equipped sword visible with Mantle hilt adapter. Fairy: Lux extends reveal, not stun.

Exact production: portrait + 4 icons; 8-direction body/sword layers; idle 6f, move 8f, basic combo 12f, parry/lunge/verdict 10/10/14f, hit 4f, defeat 8f, attune 12f; blade trails for all bearings; 3 telegraphs; 5 scalable VFX; 9 SFX + motif; parry timing test suite and mobile aim assist; standard capture matrix.

### SP_C02_01 — Tempest Ranger

Role/fantasy: storm archer controlling long lanes. Element: air/lightning. Weapon: bow. Resource: 5 Storm marks. Loop: tag → chain → consume. Skills: `SK_SP_C02_01_01 Stormneedle`, `..._02 Crosswind Mine`, `..._03 Thunderflight`; passive `SK_SP_C02_01_P01 Charged Fletching`. PvE: ranged AoE; PvP: chain targets capped at two and mine visible. Counterplay: spread, cleanse marks, pressure recovery. Equipment: bow/quiver remain visible. Fairy: Volt adds one non-damaging chain reveal.

Exact production: portrait + 4 icons; 8-direction body/bow/quiver; idle 6f, move 8f, basic 8f, three skills 10/12/14f, hit 4f, defeat 8f, attune 12f; 3 arrow/projectile models with pooling; 3 telegraphs; 6 scalable VFX; 9 SFX + motif; chain readability/accessibility color test; standard captures.

### SP_C02_02 — Veilrunner

Role/fantasy: mist scout using brief concealment and positional strikes. Element: mist/shadow. Weapon: daggers or shortbow. Resource: Veil meter built outside enemy focus, spent on mobility. Loop: obscure → relocate → expose. Skills: `SK_SP_C02_02_01 Mistfold`, `..._02 Afterimage Cut`, `..._03 Lanternbreak`; passive `SK_SP_C02_02_P01 Soft Footfall`. PvE: flank burst/scout; PvP: concealment never removes targetability inside 4m, breaks on attack, and shows proximity shimmer. Counterplay: AoE, reveal, hold formation. Equipment: paired dagger adapters or folded bow. Fairy: Nix improves self-cleanse only.

Exact production: portrait + 4 icons; 8-direction body and two weapon variants; idle 6f, move 10f, basics 10f each, skills 12/12/14f, hit 4f, defeat 8f, attune 12f; afterimage sheets; 3 telegraphs including accessibility outline; 6 VFX; 10 SFX + motif; visibility QA at all quality levels; standard captures.

### SP_C03_01 — Cinder Sage

Role/fantasy: deliberate fire scholar detonating prepared sigils. Element: fire/ash. Weapon: staff/focus. Resource: 3 Cinders. Loop: inscribe → ignite → detonate. Skills: `SK_SP_C03_01_01 Ashen Script`, `..._02 Coalstar`, `..._03 Grand Kindling`; passive `SK_SP_C03_01_P01 Banked Heat`. PvE: burst AoE; PvP: inscriptions are destroyable/visible and detonation coefficient reduced. Counterplay: leave or destroy glyph, interrupt Kindling. Equipment: staff head remains visible through flame crown. Fairy: Pyr reduces cosmetic smoke density and adds scorch-duration utility.

Exact production: portrait + 4 icons; 8-direction body/staff/focus; idle 6f, move 8f, basic 8f, skills 12/12/16f, hit 4f, defeat 8f, attune 12f; 3 projectiles/glyph meshes; 4 telegraphs; 7 scalable VFX; 10 SFX + motif; photosensitivity and ground-contrast pass; standard captures.

### SP_C03_02 — Tideshaper

Role/fantasy: water mage redirecting momentum and cooling danger. Element: water/ice. Weapon: staff/orb. Resource: Flow cycles Ebb → Surge. Loop: slow → redirect → wave. Skills: `SK_SP_C03_02_01 Rillbind`, `..._02 Returning Current`, `..._03 Moonwave`; passive `SK_SP_C03_02_P01 Tidal Rhythm`. PvE: control/support damage; PvP: displacement has immunity windows and Moonwave knock-up becomes brief lift. Counterplay: interrupt rhythm, use unstoppable, spread. Equipment: orb and staff sockets supported. Fairy: Aqua grants a minor cleanse on cycle, cooldown 30s.

Exact production: portrait + 4 icons; 8-direction body/staff/orb; idle 8f, move 8f, basic 8f, skills 12/14/16f, hit 4f, defeat 8f, attune 12f; water ribbon spline/projectile; 4 telegraphs; 7 low-overdraw VFX; 10 SFX + motif; transparent-overdraw budget validation; standard captures.

### SP_C04_01 — Grovekeeper

Role/fantasy: ancient gardener raising temporary living cover. Element: wood/earth. Weapon: crook/totem. Resource: 4 Sap. Loop: plant → nurture → harvest. Skills: `SK_SP_C04_01_01 Shelterseed`, `..._02 Elderbloom`, `..._03 Harvest Mercy`; passive `SK_SP_C04_01_P01 Deep Roots`. PvE: primary healer/warder; PvP: sprouts have health, reduced lifetime and no line-of-sight exploits. Counterplay: destroy sprouts, displace team, anti-heal. Equipment: crook/totem visible. Fairy: Flora accelerates first sprout growth by 0.25s.

Exact production: portrait + 4 icons; 8-direction body/crook/totem; idle 8f, move 8f, basic 8f, skills 12/14/16f, hit 4f, defeat 8f, attune 12f; 3 growth-stage spatial sprouts with collision policy; 4 telegraphs; 7 VFX; 10 SFX + motif; spawn/navigation/server cleanup tests; standard captures.

### SP_C04_02 — Starcaller

Role/fantasy: night-sky support forecasting safe moments. Element: astral/light. Weapon: wand/charm. Resource: 3 Constellations formed by alternating heal and damage. Loop: align → forecast → invoke. Skills: `SK_SP_C04_02_01 Guiding Star`, `..._02 Comet Cradle`, `..._03 Constellation`, passive `SK_SP_C04_02_P01 Night’s Promise`. PvE: hybrid support; PvP: Guiding Star shows route, Cradle absorb capped, Constellation cannot stack. Counterplay: pressure alignment, leave forecast, dispel shield. Equipment: wand/charm integrated into star trails. Fairy: Astra reveals forecast boundaries earlier to allies.

Exact production: portrait + 4 icons; 8-direction body/wand/charm; idle 8f, move 8f, basic 8f, skills 12/14/18f, hit 4f, defeat 8f, attune 12f; constellation line renderer and comet projectile; 4 telegraphs; 7 scalable VFX; 11 SFX + motif; flash/flicker accessibility pass; standard captures.

## Launch and post-launch delivery

Launch: four base classes, 16 base actives, four passives, all eight Mantles, class selection, build presets, both attunement quest waves, rank 1–10, equipment compatibility, fairy hook, PvE/PvP split tuning, adaptive directional runtime and full evidence. Post-launch adds optional mastery extensions or new Mantles only through a separately approved canon change. No Mantle ships partially: art, audio, controls, authority validation, accessibility, PvE/PvP and capture gates are atomic.

## Reconciliation

- Classes: 4 exactly — CLS_01 through CLS_04.
- Mantles: 8 exactly — two per class, with first unlock 24–30 and second 42–50.
- Base class skill records: 16 actives + 4 passives.
- Mantle skill records: 24 actives + 8 passives.
- Regions referenced: 5 bands, ending at cap 60.
