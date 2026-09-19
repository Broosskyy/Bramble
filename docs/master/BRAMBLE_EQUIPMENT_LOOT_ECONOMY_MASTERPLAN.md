# BRAMBLE Equipment, Loot and Economy Masterplan

Status: locked product/economy contract. Scope: level 1 through cap 60, five region bands, six equipment tiers, six dungeons, three raids and three PvP modes.

## Design promises

- Upgrades are predictable, recoverable and server-authoritative. No breakage, downgrade, paid success chance, paid stat rolls, loot boxes, stamina sales or cash-exclusive combat power.
- A newly equipped tier must be mechanically useful and visibly different on the world character. UI color alone is not progression.
- Best-in-slot paths are plural: raid, dungeon, PvP and crafted sets reach equivalent budgets with activity-specific distributions. Players may target an item; endless random affix hunting is not the core loop.
- Trading supports cooperation without making botting or market flipping the fastest progression.

## Equipment model

Slots: `PRIMARY`, `SECONDARY`, `OFFHAND`, `ARMOR`, `HELMET`, `ACCESSORY_1`, `ACCESSORY_2`, `ARTIFACT`.

- Primary: class-defining sword, bow, staff or wand/crook.
- Secondary: alternate legal weapon or class tool; swapping is out-of-combat except skills that explicitly draw it.
- Offhand: shield, quiver, focus/orb, charm/totem or compatible paired weapon.
- Armor: visible body outfit and largest defensive budget.
- Helmet: visible head layer; may be hidden locally, but ranked opponents retain silhouette-critical presentation.
- Accessories: two rings/amulets/charms; stats visible in UI, with only restrained world glints.
- Artifact: account-bound endgame build modifier with no random primary stats.

Every item definition includes stable `item_id`, display name, slot/category, tier, required level, item level, class/weapon legality, rarity, source tags, bind/trade rules, stack cap, sell value, base and secondary stats, upgrade track, set, icon, world visual, direction/state coverage, sockets, provenance and salvage result.

## Six equipment tiers

| Tier | Level and regions | Sources | Stat/rarity policy | Visible change | Upgrade ceiling |
|---|---|---|---|---|
| EQ_T01 Wayfarer | 1–12, R01 | quests, vendors, starter craft, world drops | Common–Uncommon; fixed primary stat | cloth/leather starter silhouettes, simple wood/iron weapons | +3 |
| EQ_T02 Briarforged | 13–24, R02 | zone stories, named elites, Dungeon 1–2, craft | Uncommon–Rare; one fixed secondary | reinforced hems, class-color trims, shaped offhands | +5 |
| EQ_T03 Resonant | 25–36, R03 | Mantle quests, Dungeon 2–3, craft, early PvP | Rare–Epic; two fixed secondaries | luminous sockets, stronger helmet and weapon profiles | +7 |
| EQ_T04 Crownwild | 37–48, R04 | Dungeon 4–5, Raid 1, ranked PvP, master craft | Rare–Epic; set bonuses begin | layered regional materials, animated but low-cost accents | +9 |
| EQ_T05 Elderbloom | 49–59, R05 | Dungeon 5–6, Raid 1–2, seasonal PvP, grandmaster craft | Epic–Legendary; deterministic set distributions | premium silhouette, class/Mantle-compatible spectral detail | +10 |
| EQ_T06 Canopy Ascendant | 60 endgame | all 6 dungeon keystones, Raid 2–3, elite PvP, pinnacle craft | Epic–Legendary; equal-budget activity families | endgame profile, authored VFX sockets, prestige dye channels | +12 |

Tier controls budget, not rarity. Rarity controls affix breadth and presentation within the tier: `COMMON`, `UNCOMMON`, `RARE`, `EPIC`, `LEGENDARY`. Legendary items are named, build-defining sidegrades with fixed acquisition protection; they are not strictly higher raw item level than every Epic.

## Source families and item behavior

- Quest/vendor: reliable baseline with low resale value.
- World/named unique: fixed identity and targetable spawn/quest. A named unique enters a personal pity track after first eligible defeat.
- Dungeon: role/class smart loot, tokens and boss-specific cosmetics. Normal establishes baseline; challenge difficulty adds upgrade materials, not exclusive mandatory stats.
- Raid: set tokens by slot family, deterministic exchange and prestige visuals. Personal loot; no master-loot theft.
- PvP: normalized combat gear templates plus earned equivalent-budget gear for world/PvE. Rating gates prestige, not raw competitive power.
- Crafted: tradeable pre-bind gear and bind-on-use endgame pieces. Crafters choose stat pattern and appearance family; pinnacle materials are earned, never cash-bought.
- Unique/artifact: one equipped per category; fixed effect, visible source and guaranteed path. Balance changes permit a free targeted exchange.

## Stat contract

Primary stats: vitality, strength, defense, magic, resistance, speed. Derived combat stats remain calculated centrally. Secondary ratings: precision, critical, haste, guard, healing, control resistance and resource efficiency. At cap, hard/soft caps and conversion formulas are published in-game. No hidden combat affixes.

Item budget allocation: primary/secondary/offhand 30%; armor 25%; helmet 12%; two accessories 16%; artifact 17%. Two-item and four-item set bonuses consume their set’s total budget and provide playstyle options, not multiplicative mandatory stacking. PvP has separate coefficients and crowd-control duration.

## Visible equipment and production

Primary, secondary when drawn, offhand, armor and helmet use synchronized directional layers. Each visible record supplies eight-direction idle and movement; weapons additionally supply anticipation/contact/recovery alignment for every legal base and Mantle attack. It declares pivot, scale, body/hand/back sockets, depth per bearing, mirror restriction, dye masks, mipmaps, atlas, mobile material/overdraw budget and provenance. Missing action coverage is `PARTIAL`, never silently substituted.

Accessories use UI art plus at most one shared low-cost accent. Artifacts use a small class-neutral aura socket that can be disabled for accessibility/performance. Upgrade glow appears only at +6, +9 and +12 and never obscures telegraphs.

## Loot and item taxonomy

Stable prefixes:

- `EQ_`: equippable gear; `WP_` weapon; `OH_` offhand; `AR_` armor; `HM_` helmet; `AC_` accessory; `AF_` artifact.
- `CO_`: consumable (healing, utility, food); no consumable usable in ranked PvP unless mode-provided.
- `MA_`: gathered/refined/catalyst material.
- `RE_`: recipe or profession knowledge.
- `QT_`: quest item, non-tradeable and separate quest storage.
- `TK_`: dungeon, raid, PvP, event and catch-up token.
- `CS_`: cosmetic/dye/emote; no stats.
- `CU_`: currencies represented in wallet, never inventory stacks.
- `MI_`: miscellaneous lore or vendor item.

Loot tables are server-versioned and use weighted entries plus guaranteed counters. Each roll records source instance, eligibility, table version, result and bind state. The client receives outcomes, never rolls them.

## Quantified launch icon requirement

All icons require a 256×256 layered source, transparent master, 128×128 inventory export, 64×64 tooltip/loot export and 48×48 HUD/vendor export; silhouette must survive at 48px. Exact launch budget:

| Icon group | Unique icons |
|---|---:|
| Weapons: 4 class families × 6 tiers × 2 silhouettes | 48 |
| Offhands: 4 class families × 6 tiers | 24 |
| Armor: 4 classes × 6 tiers | 24 |
| Helmets: 4 classes × 6 tiers | 24 |
| Accessories: 6 tiers × 4 forms | 24 |
| Artifacts: 8 Mantle-aligned + 4 universal | 12 |
| Consumables | 20 |
| Materials: gathered 20, refined 12, catalysts 8 | 40 |
| Recipes | 16 |
| Quest items | 24 |
| Tokens: dungeon 6, raid 3, PvP 3, event/catch-up 4 | 16 |
| Cosmetics/dyes | 24 |
| Miscellaneous/lore | 8 |
| Currency wallet icons | 8 |
| **Total unique launch icons** | **284** |

Rarity borders, lock, bound, crafted, upgrade and new-item indicators are nine reusable overlays and are not counted as item icons. Palette swaps do not count as unique icons. Post-launch items add icons only after silhouette review.

## Upgrade system

- Gear earns item XP from level-appropriate play or consumes activity-neutral Temper materials. Each + rank has a fixed visible cost.
- Upgrade success is 100%. No failure, destruction, downgrade or protection consumable exists.
- Tier ceiling follows the table. Crossing to a new equipment tier requires a replacement item, but 60% of invested non-premium upgrade materials transfer through salvage.
- At +3/+6/+9/+12, the player selects one of two fixed minor tuning nodes; switching costs ordinary gold and is free for seven days after a balance patch.
- Duplicate named items convert into source tokens plus salvage; the first duplicate also unlocks its appearance.

## Crafting

Professions: gathering, refining and one production specialty at a time; changing specialty preserves learned recipes. Recipes specify exact outputs. Gear recipes allow selection among published stat patterns, not random rerolls. Work orders escrow materials and payment server-side, show final output, and prevent substitution. Daily crafting limits apply only to pinnacle bind-on-use catalysts; ordinary production is unrestricted.

Pity and safety:

- Dungeon boss: desired slot token guaranteed by the third eligible clear; full direct item by the sixth if unclaimed.
- Raid boss: one slot-family token each weekly first kill; any four relevant tokens buy the exact piece.
- Named world unique: guaranteed by the eighth eligible personal defeat.
- Craft discovery: no random recipe failure; research bar completes deterministically.
- Bad-luck counters are character-visible, survive season changes where source remains, and cannot be reset by grouping.

Catch-up:

- When a new tier/raid releases, story and dungeon currency buy previous-tier baseline.
- Returning players receive objectives, not instant top gear: one full prior-tier baseline set over seven flexible tasks.
- Account-wide unlocks accelerate alt access; alts still learn class kits.
- Old materials convert forward at a published rate and never become worthless overnight.

## Currency model

Exactly eight launch wallet currencies:

1. `CU_GOLD` — broad earned soft currency; repairs, vendors, crafting and market fees.
2. `CU_LEAF` — account-bound exploration/quest currency; regional cosmetics and catch-up.
3. `CU_DUNGEON_SEAL` — six dungeons share one seal with boss tags for targeting.
4. `CU_RAID_CREST` — three raids; weekly earned cap, no purchase.
5. `CU_ARENA_MARK` — duel/arena/battleground participation and season gear.
6. `CU_CRAFT_NOTE` — profession progression and recipes.
7. `CU_EVENT_PETAL` — live-event cosmetics; expires only after a clearly shown grace vendor.
8. `CU_PREMIUM` — paid cosmetics/convenience only; cannot buy power, gold, tradeable goods, pity progress or competitive entry.

Currency caps are displayed before rewards. Overflow converts to a useful non-tradeable fallback or mails a claim; it is never silently lost.

## Economy, trade and market

- Tradeable: ordinary materials, consumables, recipes, cosmetics and crafted gear before bind. Bind-on-pickup: raid drops, ranked rewards, artifacts and quest gear. Equipping/using eligible gear binds it.
- Direct trade uses a two-party escrow window, both confirmations reset after any change, and server revalidates ownership/caps.
- Regional market is a server-authoritative order book. Listings show unit and total price, recent median, duration and fee. No client-to-client item transfer.
- Anti-manipulation: rate/volume anomaly detection, delayed settlement for suspicious new accounts, price-band warnings rather than forced prices, provenance logs and reversible moderation holds.
- No real-money trading integration, cash-out, paid auction priority or premium-currency market.

Gold faucets: quests, first clears, vendor trash, public events and bounded daily objectives. Gold sinks: 5% market fee, crafting/refining, upgrade ranks, appearance transmutation, build retuning, guild services and optional fast travel. Repair is a small service fee with no durability destruction. Sink/faucet telemetry is reviewed weekly by cohort and region; changes are announced and do not confiscate balances.

## Reward presentation and anti-frustration

Routine drops use compact world beam, sound and auto-loot radius. Upgrades use visible character refresh. Legendary, Mantle and collection completions use distinct but skippable audiovisual moments. Inventory has material/quest tabs, stack consolidation, search, filters, compare and “source” lookup. Full inventory routes eligible loot to a 72-hour recovery mailbox.

Prohibited patterns: corpse runs for gear, XP loss, upgrade failure, required spawn camping, unrestricted need/greed, untelegraphed weekly lockouts, randomized paid chests, paid rerolls, purchasable PvP stats, artificial inventory pressure and obsolete-currency traps.

## Authority and audit

Server owns inventory, wallet, eligibility, loot rolls, pity, crafting, upgrades, binding, mail, trades and market settlement. Every mutation is idempotent with transaction ID, expected version, source/sink ledger entries and replay-safe response. High-value grants and trades retain audit provenance. Disconnect recovery resumes or safely rolls back escrow; it never duplicates.

## Reconciliation

- Equipment tiers: 6 exactly, covering levels 1–60.
- Slots represented: primary, secondary, offhand, armor, helmet, two accessories and artifact.
- Dungeon/raid/PvP sourcing: 6 dungeons, 3 raids and all 3 PvP modes.
- Wallet currencies: 8 exactly.
- Launch item icons: 284 unique, plus 9 reusable overlays.
