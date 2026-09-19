# BRAMBLE World Content Masterplan

Status: launch content lock  
Scope: documentation only; level cap 60  
Presentation: mobile-first spatial 2.5D, hybrid/limited yaw (approximately ±45°), one world shared by landscape and portrait  
Composition lock: M04.31A lessons are mandatory—authored transparent road modules, planted path edges, house/rest/route/forest/combat pockets, clear foreground/midground/background, restrained clutter, authored landmarks, low shadow count, and no primitive hero geometry.

## 1. Launch contract and hierarchy

`World > Region > Map > Cluster/Pocket > Encounter or Social Space > Instance Portal`

- Launch is exactly five contiguous regions, 25 maps (five per region), one hub per region, six dungeons, three raids, 40 standard field enemies, 10 elite field enemies, five open-world minibosses, 35 named NPCs, 90 main quests, 60 side quests, and 25 repeatables.
- Level bands are locked: R01 Amberway Vale 1–12; R02 Briarwood Reach 13–24; R03 Sunmere Coast 25–36; R04 Cinderpeak March 37–48; R05 Starfall Fen 49–60.
- Launch maps contain the complete cap-60 journey. A portal shown on a launch map must either lead to one of the nine launch instances or be visibly dormant and non-interactive.
- Post-launch may add instanced wings, challenge variants, seasonal event overlays, housing interiors, and regions beyond R05. It must not raise launch map count, relabel launch IDs, insert progression between locked regions, or treat dormant portals as launch content.
- World traversal is route-led: hub → safe threshold → two field maps → climax map, with at least one return loop and one readable shortcut per field map.
- Safe/social pockets never overlap required combat. Combat pockets preserve target separation, retreat lanes, camera sightlines, and portrait-safe context.
- “Mantle quest” means a region’s capstone attunement chain that proves traversal, field mastery, dungeon clearance, and regional stewardship; it is not an equipment slot.

## 2. Region plans

### R01 — Amberway Vale

- **ID/name/theme/biome/lore/levels:** `R01`, Amberway Vale; hopeful amber-road frontier; meadow, orchard, reed moor, shallow woodland; old waystones wake as the Vale’s communal roads are restored; levels 1–12.
- **Hub/settlements/map count:** hub `MAP_R01_01 Ambercross`; settlements Ambercross, Honeywick Farmstead, Moorwatch Camp; exactly five maps.
- **Maps/routes:** Ambercross → Honeyglass Fields → Amberway Moor → Goldleaf Verge → Waystone Hollow; farm loop returns from Verge to Ambercross; Hollow portal continues to R02.
- **Landmarks:** Ambercross Hall, Bell Orchard, Lantern Boardwalk, Elder Goldleaf, First Waystone.
- **Dungeons/raids/bosses:** `D01 Rootbound Cellar`; no raid; miniboss `MB_R01_01 Bellhide Grazer`; dungeon boss `BOSS_D01`.
- **Enemy families:** Moorling (canonical), grazer, burrower, moth, bramble, reed spirit; eight standard and two elite variants are enumerated below.
- **NPC needs:** seven named roles; merchant and blacksmith bases can be reused, while keeper, scout, farmer, healer, scholar require unique silhouettes or modular dress.
- **Hazards/resources:** mud slow, pollen burst, thorn snare; amber shard, meadow herb, thornberry, reed fiber, softwood, clearwater fish.
- **Loot/equipment:** novice leather/cloth, copper tools, meadow charms, amber trinkets; readable one-handed weapon silhouettes.
- **Mantle quests:** `MQ_R01_MANTLE` “The First Road”—relight three route stones, defeat Bellhide, clear D01, bind the Amber Mantle.
- **PvP:** opt-in hub sparring ring only; no open-world PvP, no quest/resource advantage.
- **Environment assets:** meadow/cobble/riverbank/bridge/cottage/inn/gate/garden/apple tree/thornberry/milestone families; reeds/willow/glow stump available; orchard, moor-boardwalk, and rotation-safe regional variants remain production work.

### R02 — Briarwood Reach

- **ID/name/theme/biome/lore/levels:** `R02`, Briarwood Reach; guarded woodland ascent; briar forest, moss ravine, rain-dark ruins; the Reach grew around living boundary hedges now turning inward; levels 13–24.
- **Hub/settlements/map count:** hub `MAP_R02_01 Briarwatch`; settlements Briarwatch, Mossbell Camp, Greenwarden Lodge; exactly five maps.
- **Maps/routes:** Briarwatch → Foxglove Run → Mossbell Ravine → Thornvault Wood → Warden’s Crown; Ravine lift and Crown root-tunnel form return routes; Crown gate continues to R03.
- **Landmarks:** Briarwatch Gate, Foxglove Arch, Mossbell Falls, Thornvault Heart, Warden Beacon.
- **Dungeons/raids/bosses:** `D02 Thornvault Burrows`; no raid; miniboss `MB_R02_01 Crownroot Stag`; dungeon boss `BOSS_D02`.
- **Enemy families:** rootling, thornling, moss guardian, spore beast, bark beetle, wisp; eight standard and two elite variants below.
- **NPC needs:** seven named roles; merchant/blacksmith directional bases reusable with woodland dress; warden, herbalist, pathfinder, archivist, beastkeeper need unique heads/props.
- **Hazards/resources:** thorn walls, spore clouds, falling branch tells; ironbark, foxglove, moss silk, resin, raincap, silverleaf.
- **Loot/equipment:** briar leather, warden mail, resin bows, moss focuses, rootguard shields.
- **Mantle quests:** `MQ_R02_MANTLE` “The Living Boundary”—open three hedge seals, defeat Crownroot, clear D02, bind the Briar Mantle.
- **PvP:** opt-in 3v3 practice grove adjacent to hub; normalized stats, cosmetic/reputation rewards only.
- **Environment assets:** grass/soil, cliff/ramp/stair, bridge, gate, cottage, wilds building and vegetation source sheets; dense canopy, rotation-safe trunks, briar barriers, rain treatment, and woodland ruin set need extraction/authorship.

### R03 — Sunmere Coast

- **ID/name/theme/biome/lore/levels:** `R03`, Sunmere Coast; bright trade coast over drowned history; beach, salt marsh, terrace town, tidal ruin; tide-lenses once guided ships and now reveal the buried Mere; levels 25–36.
- **Hub/settlements/map count:** hub `MAP_R03_01 Sunmere Haven`; settlements Sunmere Haven, Gullrest Quay, Lenskeeper Terrace; exactly five maps.
- **Maps/routes:** Haven → Saffron Strand → Brineglass Marsh → Tidelens Ruins → Beacon Isle; ferry and tidal causeway provide paired routes; beacon passage continues to R04.
- **Landmarks:** Sunmere Quay, Saffron Dunes, Brineglass Mirror, Tidelens Orrery, Dawn Beacon.
- **Dungeons/raids/bosses:** `D03 Brineglass Grotto`; `RAID01 The Drowned Orrery`; miniboss `MB_R03_01 Saltcrown Matron`; bosses `BOSS_D03`, `BOSS_R01`.
- **Enemy families:** shore crab, lantern moth, glassfin, mire eel, salt wisp, dune prowler; eight standard and two elite variants below.
- **NPC needs:** seven named roles; merchant base reusable; harbor master, tide scholar, fisher, navigator, lenskeeper, raid liaison require coastal dress/props.
- **Hazards/resources:** timed tide lanes, salt glare telegraph masking, brine pools; shellstone, saffron reed, brine pearl, driftwood, sunscale, lens glass.
- **Loot/equipment:** coastweave armor, tideguard mail, coral blades, lens focuses, brine resistance charms.
- **Mantle quests:** `MQ_R03_MANTLE` “Where Day Meets Tide”—align coast lenses, defeat Saltcrown, clear D03, bind the Sun Mantle; RAID01 is not required for leveling completion.
- **PvP:** `PVP_02` 3v3 Arena queue and beacon-control training court in the hub; no world-map combat.
- **Environment assets:** water/riverbank/footbridge/portal/dungeon entrance and generic landmarks exist; sand, shoreline foam, docks, boats, tidal ruins, marine foliage, and coast buildings require authored families.

### R04 — Cinderpeak March

- **ID/name/theme/biome/lore/levels:** `R04`, Cinderpeak March; disciplined passage through a living volcanic frontier; ash steppe, basalt pass, forge settlement, caldera; ward-forges regulate the mountain’s ember pressure; levels 37–48.
- **Hub/settlements/map count:** hub `MAP_R04_01 Cinderward`; settlements Cinderward, Ashen Relay, Forgefall Station; exactly five maps.
- **Maps/routes:** Cinderward → Embergrass Steppe → Sootwind Pass → Forgefall Shelf → Caldera Gate; mine tram and cooled-lava shelf are shortcuts; Gate descends to R05.
- **Landmarks:** Cinderward Bastion, Embergrass Rings, Sootwind Needles, Forgefall Crucible, Caldera Seal.
- **Dungeons/raids/bosses:** `D04 Embervein Foundry`; `RAID02 The Caldera Ward`; miniboss `MB_R04_01 Ashmantle Ram`; bosses `BOSS_D04`, `BOSS_R02`.
- **Enemy families:** copper mole, ember beetle, ash hound, slagling, cinder hawk, forge wisp; eight standard and two elite variants below.
- **NPC needs:** seven named roles; blacksmith base reusable; marshal, surveyor, engineer, quartermaster, vent tender, raid liaison need region-specific protective gear.
- **Hazards/resources:** vent cones, falling cinders, heat stacks, minecart crossings; copper ore, emberglass, basalt, firebloom, furnace coal, salamander scale.
- **Loot/equipment:** marchplate, heatweave, tempered weapons, ember focuses, ventguard accessories.
- **Mantle quests:** `MQ_R04_MANTLE` “Hold the Mountain”—stabilize vents, defeat Ashmantle, clear D04, bind the Cinder Mantle; RAID02 remains optional endgame progression.
- **PvP:** duel terrace plus `PVP_03` 8v8 Battleground queue and Briar Beacon practice lane in the hub.
- **Environment assets:** copper mine/crystal cave source sheets, cliff/elevation/entrance/portal/VFX families exist; basalt modules, forge interiors, lava/heat materials, ash vegetation, machinery, and multi-angle fortifications need production.

### R05 — Starfall Fen

- **ID/name/theme/biome/lore/levels:** `R05`, Starfall Fen; luminous final frontier where sky-metal changes wetland life; star fen, flooded archive, crystal mire, night reedland; fallen fragments resonate with the five Mantles and threaten to rewrite the watershed; levels 49–60.
- **Hub/settlements/map count:** hub `MAP_R05_01 Starfall Refuge`; settlements Starfall Refuge, Reedlight Enclave, Astral Survey Camp; exactly five maps.
- **Maps/routes:** Refuge → Gleamreed Basin → Fallen Archive → Nightglass Mire → Starfall Cradle; skiff route and archive causeway loop back; Cradle is launch’s final world map.
- **Landmarks:** Refuge Lantern, Gleamreed Choir, Fallen Archive, Nightglass Observatory, Starfall Cradle.
- **Dungeons/raids/bosses:** `D05 Fallen Star Archive`, `D06 Nightglass Depths`; `RAID03 Heart of Starfall`; miniboss `MB_R05_01 Cometback Behemoth`; bosses `BOSS_D05`, `BOSS_D06`, `BOSS_R03`.
- **Enemy families:** crystal beetle, ruins wisp, starling ooze, reed sentinel, mire prowler, shardwing; eight standard and two elite variants below.
- **NPC needs:** seven named roles; scholar, ferrier, salvager, archivist, mantle keeper, quartermaster, raid liaison all need high-tier silhouettes; merchant base may support quartermaster only.
- **Hazards/resources:** deep-water exclusion, crystal resonance pulses, false-light lure, meteor telegraphs; star iron, nightglass, luminous reed, archive vellum, void pearl, comet moss.
- **Loot/equipment:** starforged capstone sets, nightglass weapons, mantle catalysts, raid-ready accessories; no launch item exceeds cap-60 progression.
- **Mantle quests:** `MQ_R05_MANTLE` “Five Lights, One Sky”—recover four echoes, defeat Cometback, clear D05 and D06, bind the Star Mantle; final main story ends before RAID03, which is endgame.
- **PvP:** ranked `PVP_02` and `PVP_03` terminals in the hub; open fen remains PvE and no fourth mode is introduced.
- **Environment assets:** swamp willow/reeds/glow stump/thornberry, water, portals, ruins source sheets and generic VFX exist; star-crystal wetland, archive kit, night water, skiffs, observatory, meteor arena, and luminous LOD families are missing.

## 3. Map-by-map launch definitions

### R01 maps

- **`MAP_R01_01` Ambercross (hub, L1–12):** Purpose onboarding/social/crafting; entrances new-player arrival, R01_02 south, R01_04 farm loop, D01 cellar; routes Hall spine and market loop; combat none except sparring tutorial; monsters none; elites/miniboss none; NPCs NPC_R01_01/02/03/04/05; quest targets Hall, forge, board, Mantle plinth; resources tutorial herb/ore nodes only; landmarks Hall/milestone/gate; social pockets inn, forge, fountain; secrets rooftop bell cache; treasure one account chest; portals D01 entrance, R02 waystone dormant until L12; event harvest square; respawn Hall; safe entire hub except sparring ring; clusters foreground gate/midground Hall/background orchard; depth H0 streets/H1 porches; mobile density 10 players +7 NPCs visible target, low transparent overlap; required assets authored cottage/Hall, inn, workshop, roads, garden, gate, milestone, market props, hub signage, safe-zone/VFX.
- **`MAP_R01_02` Honeyglass Fields (L1–5):** Purpose first field/gathering; entrances Ambercross north, Moor south, Verge shortcut east; routes farm lane and irrigation loop; combat three broad pockets; monsters EN_R01_S01/S02/S03; elite EN_R01_E01 at bell orchard; miniboss none; NPCs NPC_R01_06 plus two reused farmhands; quest targets hives, scare markers, broken sluice; resources herb, softwood, amber shard; landmarks Bell Orchard/windwheel; social pocket farm porch; secrets irrigation culvert; treasure two commons/one elite cache; portals none; dungeon none; event pollen swarm; respawn farmstead; safe porch/road fork; clusters crop cards/fences/trees; depth H0 fields/H1 berm; mobile density 6 enemies per pocket, max 18 transparent crop cards; required assets meadow, dirt/cobble transitions, crops, orchard, hive, fence, farm facade, pollen VFX.
- **`MAP_R01_03` Amberway Moor (L4–8):** Purpose canonical Moorling field and route literacy; entrances Fields west, Verge north; routes raised boardwalk and mud shortcut; combat four low-clutter islands; monsters EN_R01_S01/S04/S05/S06; elite EN_R01_E02; miniboss none; NPCs NPC_R01_07 at Moorwatch; quest targets lost packs, reed lights, Moorling nests; resources reeds, thornberry, clearwater fish; landmarks Lantern Boardwalk/glow stump ring; social pocket Moorwatch fire; secrets willow hollow; treasure three pools; portals event rift only during event; dungeon none; event reedlight migration; respawn Moorwatch; safe camp and waystone; clusters reeds/willow/glow stumps; depth H0 mud/H1 boardwalk; mobile density max 7 enemies/20 vegetation cards per view; required assets canonical Moorling Kit60/70/71, willow/reeds/glow stump, water/mud, footbridge/boardwalk, camp props, four-direction fallback handling.
- **`MAP_R01_04` Goldleaf Verge (L7–10):** Purpose traversal/combat mix and hub return loop; entrances Moor south, Hollow east, Ambercross shortcut west; routes leaf road, orchard ridge; combat four pockets; monsters EN_R01_S02/S03/S07/S08; elite EN_R01_E01; miniboss MB_R01_01 in bell ring; NPCs NPC_R01_06 reused; quest targets blight roots, bells, courier posts; resources amber shard, herb, fruit; landmarks Elder Goldleaf/bell ring; social pocket ranger lean-to; secrets canopy fade alcove; treasure miniboss chest +2 caches; portals none; dungeon none; event falling-gold caravan; respawn lean-to; safe west fork; clusters golden shrubs/oak/rocks; depth H0 road/H1 ridge/H2 tree roots; mobile density 6 enemies and 3 large occluders max; required assets rotation-safe elder tree, shrubs, ridge modules, bells, caravan props, canopy fade volumes.
- **`MAP_R01_05` Waystone Hollow (L10–12):** Purpose regional climax/Mantle; entrances Verge west, R02 portal north, D01 stair; routes outer ring and center spoke; combat three trial pockets; monsters EN_R01_S05/S07/S08; elites both R01 elites in separate trials; miniboss MB_R01_01 quest rematch only if not cleared; NPCs NPC_R01_01 and NPC_R01_07 during quests; quest targets three waystones/Mantle altar; resources amber shard/thornberry; landmarks First Waystone; social pocket pilgrim camp; secrets rear altar rune; treasure Mantle chest; portals R02 active after MQ, D01; dungeon D01; event waystone surge; respawn pilgrim camp; safe camp/altar after clear; clusters ruin ring/thorn edges; depth H0 arena/H1 altar; mobile density 8 enemies only in staged waves; required assets milestone/portal/ruin modules, altar, dungeon entrance, restrained amber VFX, encounter gates.

### R02 maps

- **`MAP_R02_01` Briarwatch (hub, L13–24):** Purpose woodland services/story reset; entrances R01 gate, R02_02, R02_04 tunnel; routes gate-market-lodge loop; combat sparring grove only; monsters/elites/miniboss none; NPCs NPC_R02_01/02/03/04/05; quest targets lodge, apothecary, archive; resources demonstration moss/resin; landmarks Briarwatch Gate/Warden Lodge; social pockets inn, grove, overlook; secrets hedge passage; treasure one reputation chest; portals D02 board and practice PvP; event warden muster; respawn lodge; safe hub; clusters framed cottages/briar walls/canopy; depth H0 lane/H1 decks; mobile density 10 players +7 NPC target, canopy fade mandatory; required assets woodland building skins, living gate, hedges, lodge, market, signage, rain-safe materials.
- **`MAP_R02_02` Foxglove Run (L13–17):** Purpose readable forest lanes; entrances hub west, ravine east; routes creek road and upper hedge; combat four clearings; monsters EN_R02_S01/S02/S03; elite EN_R02_E01; miniboss none; NPCs NPC_R02_06; quest targets trail seals, resin taps, trapped scouts; resources foxglove/resin/softwood; landmarks Foxglove Arch; social pocket scout blind; secrets creek cave; treasure three caches; portals none; dungeon none; event rootling march; respawn blind; safe west arch; clusters trunks/briar/flowers; depth H0 creek/H1 hedge shelf; mobile density 6 enemies, 2 large trunks/view; required assets rootling family, forest ground, creek, arch, rotation-safe trunks, foxglove, resin props.
- **`MAP_R02_03` Mossbell Ravine (L16–20):** Purpose elevation and hazard training; entrances Run west, Thornvault north; routes ravine floor/ramp/rope bridge; combat four terraces; monsters EN_R02_S03/S04/S05/S06; elite EN_R02_E02; miniboss none; NPCs NPC_R02_07; quest targets bells, spore vents, lift gears; resources moss silk/raincap/ironbark; landmarks Mossbell Falls; social pocket lift station; secrets waterfall ledge; treasure elite cache +2; portals none; dungeon none; event spore rain; respawn station; safe lift; clusters cliff/waterfall/moss cards; depth H0 floor/H1 ledges/H2 bridge; mobile density max 6 enemies on one height, hazard telegraphs unobscured; required assets cliff/ramp/stair/bridge, waterfall, moss, bell flora, lift, spore VFX.
- **`MAP_R02_04` Thornvault Wood (L19–22):** Purpose dense-threat map with alternate routes; entrances Ravine south, Crown east, hub tunnel west; routes guarded road and thorn maze; combat five pockets; monsters EN_R02_S02/S05/S07/S08; elite both R02 elites; miniboss MB_R02_01 patrol edge; NPCs NPC_R02_06 reused; quest targets hedge anchors, beast tracks; resources ironbark/silverleaf/resin; landmarks Thornvault Heart; social pocket Greenwarden Lodge; secrets root tunnel; treasure miniboss chest +3; portals D02 entrance; dungeon D02; event moving hedge; respawn Lodge; safe Lodge/tunnel mouth; clusters dense canopy but combat clearings low clutter; depth H0 paths/H1 roots; mobile density 7 enemies, fade no more than 35% screen; required assets thorn maze, heart tree, lodge, D02 entrance, root tunnels, Crownroot silhouette.
- **`MAP_R02_05` Warden’s Crown (L22–24):** Purpose region climax/Mantle; entrances Wood west, R03 descent east; routes spiral ascent and service switchbacks; combat three trials; monsters EN_R02_S04/S07/S08; elites staged; miniboss MB_R02_01; NPCs NPC_R02_01/NPC_R02_07 quest phases; quest targets beacon, boundary seals; resources silverleaf/ironbark; landmarks Warden Beacon; social pocket summit camp; secrets rear beacon niche; treasure Mantle chest; portals R03 after MQ; dungeon none; event crown storm; respawn summit camp; safe camp/beacon after clear; clusters cliffs/root arches/beacon; depth H0 lower ring/H1 crown/H2 beacon; mobile density 8 staged enemies; required assets summit kit, beacon, root arches, weather VFX, long-distance woodland backdrop.

### R03 maps

- **`MAP_R03_01` Sunmere Haven (hub, L25–36):** Purpose coast services/ferry/social; entrances R02 road, Strand, Ruins ferry; routes quay-market-terrace loop; combat practice dock only; monsters/elites/miniboss none; NPCs NPC_R03_01/02/03/04/05; quest targets harbor office, tide board, lens terrace; resources demo fish/shell; landmarks Sunmere Quay; social pockets market, pier, bathhouse terrace; secrets underpier cache; treasure one trade chest; portals D03 board/PvP beacon; event regatta; respawn quay; safe hub; clusters docks/buildings/palms; depth H0 quay/H1 terrace; mobile density 12 players +7 NPC target, reflective water budget fixed; required assets coastal buildings, docks/boats, terrace, market, water/foam, ferry, safe-zone markers.
- **`MAP_R03_02` Saffron Strand (L25–29):** Purpose open sightline combat; entrances Haven north, Marsh east; routes beach and dune ridge; combat four broad pockets; monsters EN_R03_S01/S02/S03; elite EN_R03_E01; miniboss none; NPCs NPC_R03_06; quest targets nests, cargo, saffron beds; resources saffron reed/shellstone/driftwood; landmarks Saffron Dunes; social pocket Gullrest camp; secrets tide cave; treasure three tide caches; portals none; dungeon none; event wreck salvage; respawn camp; safe camp; clusters dunes/reeds/wreckage; depth H0 shore/H1 dunes; mobile density 7 enemies, limited foam particles; required assets sand/dune/shoreline, shore creatures, wreck, camp, saffron flora.
- **`MAP_R03_03` Brineglass Marsh (L28–32):** Purpose tide timing and gathering; entrances Strand west, Ruins east; routes high boardwalk/low tidal flats; combat four islands; monsters EN_R03_S03/S04/S05/S06; elite EN_R03_E02; miniboss MB_R03_01 center tide; NPCs NPC_R03_07; quest targets tide gauges, pearl pools; resources brine pearl/sunscale/reeds; landmarks Brineglass Mirror; social pocket gauge hut; secrets submerged path at low tide; treasure miniboss chest +2; portals D03 grotto; dungeon D03; event mirror bloom; respawn hut; safe boardwalk junction; clusters water/reed/glass pools; depth H0 flats/H1 boardwalk; mobile density 6 enemies, one reflection layer; required assets tide states, boardwalk, mirror pools, Saltcrown, grotto entrance, readable brine hazard.
- **`MAP_R03_04` Tidelens Ruins (L31–34):** Purpose puzzle-combat/raid foreshadow; entrances Marsh west, Beacon ferry; routes outer colonnade and lens halls; combat five rooms/pockets; monsters EN_R03_S02/S05/S07/S08; both elites; miniboss optional Saltcrown rematch event; NPCs NPC_R03_07 reused/NPC_R03_05; quest targets four lenses, inscriptions; resources lens glass/shellstone; landmarks Tidelens Orrery; social pocket expedition camp; secrets lens-beam vault; treasure four puzzle chests; portals RAID01 lobby; dungeon none; event lens alignment; respawn camp; safe camp/solved orrery; clusters ruins/lenses/water channels; depth H0 court/H1 galleries; mobile density 8 enemies staged, beam VFX capped; required assets coastal ruin kit, lens machinery, colonnades, raid portal, beam/refraction VFX.
- **`MAP_R03_05` Beacon Isle (L34–36):** Purpose region climax/Mantle; entrances Ruins ferry, R04 skybridge; routes isle ring and beacon stair; combat three trials; monsters EN_R03_S06/S07/S08; elites staged; miniboss MB_R03_01 if outstanding; NPCs NPC_R03_01/NPC_R03_05; quest targets beacon mirrors/Mantle altar; resources lens glass/sunscale; landmarks Dawn Beacon; social pocket keeper terrace; secrets lamp chamber; treasure Mantle chest; portals R04 after MQ; dungeon none; event dawn defense; respawn terrace; safe terrace/beacon after clear; clusters rocks/beacon/wind flora; depth H0 ring/H1 stairs/H2 lamp; mobile density 7 staged enemies, horizon preserved; required assets lighthouse/beacon, isle rocks, wind props, skybridge/transition, dawn VFX.

### R04 maps

- **`MAP_R04_01` Cinderward (hub, L37–48):** Purpose march services/heat preparation; entrances R03 skyroad, Steppe, Shelf tram; routes bastion-forge-depot loop; combat duel terrace only; monsters/elites/miniboss none; NPCs NPC_R04_01/02/03/04/05; quest targets marshal table, forge, vent office; resources demo ore/firebloom; landmarks Cinderward Bastion; social pockets mess, forge gallery, overlook; secrets coolant conduit; treasure one service chest; portals D04 board/PvP convoy; event forge ceremony; respawn bastion; safe hub; clusters fort/forge/rock; depth H0 yard/H1 ramparts; mobile density 10 players +7 NPC target, smoke opacity capped; required assets basalt fort, forge, machinery, tram, heat-safe signage/materials.
- **`MAP_R04_02` Embergrass Steppe (L37–41):** Purpose transition to heat hazards; entrances hub west, Pass east; routes marker road and grass basin; combat four pockets; monsters EN_R04_S01/S02/S03; elite EN_R04_E01; miniboss none; NPCs NPC_R04_06; quest targets vent flags, herd tracks; resources copper/firebloom/coal; landmarks Embergrass Rings; social pocket survey camp; secrets cooled tube; treasure three caches; portals none; dungeon none; event cinder gust; respawn camp; safe camp/markers; clusters ember grass/basalt/vents; depth H0 basin/H1 rings; mobile density 7 enemies, 12 grass cards, vent tells 1.5s; required assets ash terrain, ember grass, vent VFX, basalt, camp, heat fauna.
- **`MAP_R04_03` Sootwind Pass (L40–44):** Purpose narrow route discipline; entrances Steppe south, Shelf north; routes sheltered switchback and risky ridge; combat four bays; monsters EN_R04_S03/S04/S05/S06; elite EN_R04_E02; miniboss none; NPCs NPC_R04_07; quest targets wind vanes, stranded caravan; resources basalt/emberglass/coal; landmarks Sootwind Needles; social pocket Ashen Relay; secrets needle crevice; treasure elite chest +2; portals none; dungeon none; event soot squall; respawn Relay; safe Relay; clusters cliffs/needles/smoke; depth H0 pass/H1 ridge/H2 lookout; mobile density 6 enemies, smoke never covers target rings; required assets cliff switchbacks, basalt needles, soot/weather VFX, relay building, caravan.
- **`MAP_R04_04` Forgefall Shelf (L43–46):** Purpose machinery combat and dungeon access; entrances Pass west, Gate east, hub tram; routes factory apron and cooled channel; combat five pockets; monsters EN_R04_S02/S05/S07/S08; both elites; miniboss MB_R04_01 at slag basin; NPCs NPC_R04_06 reused; quest targets valves, slag cranes; resources copper/emberglass/furnace coal; landmarks Forgefall Crucible; social pocket station; secrets maintenance shaft; treasure miniboss chest +3; portals D04; dungeon D04; event runaway carts; respawn station; safe station/tram; clusters machinery/channels/cranes; depth H0 apron/H1 catwalk; mobile density 7 enemies, moving hazards capped at 2; required assets foundry exterior, rails/carts, slag/lava, valves, cranes, D04 entrance, Ashmantle.
- **`MAP_R04_05` Caldera Gate (L46–48):** Purpose region climax/Mantle/raid threshold; entrances Shelf west, R05 descent, RAID02 ward lift; routes seal ring and vent stairs; combat three trials; monsters EN_R04_S04/S07/S08; elites staged; miniboss MB_R04_01; NPCs NPC_R04_01/NPC_R04_07; quest targets four vents/seal; resources emberglass/firebloom; landmarks Caldera Seal; social pocket ward camp; secrets seal undercroft; treasure Mantle chest; portals R05 after MQ/RAID02; dungeon none; event pressure surge; respawn camp; safe camp/seal after clear; clusters caldera rim/seal machinery; depth H0 rim/H1 seal deck; mobile density 8 staged enemies, one major eruption VFX; required assets caldera panorama, seal, ward lift, raid portal, pressure VFX, cooled descent.

### R05 maps

- **`MAP_R05_01` Starfall Refuge (hub, L49–60):** Purpose capstone services/endgame assembly; entrances R04 descent, Basin, Archive skiff; routes lantern-market-dock-observatory loop; combat practice constellation only; monsters/elites/miniboss none; NPCs NPC_R05_01/02/03/04/05; quest targets Mantle chamber, archive desk, raid board; resources demo star iron/reed; landmarks Refuge Lantern; social pockets dock, hall, observatory; secrets lantern loft; treasure one weekly cache; portals D05/D06/RAID03 boards and PvP; event starfall vigil; respawn Hall; safe hub; clusters stilt buildings/reeds/crystals; depth H0 boardwalk/H1 decks; mobile density 12 players +7 NPC target, luminous overdraw capped; required assets stilt settlement, skiffs, observatory, lantern, star crystal, endgame service props.
- **`MAP_R05_02` Gleamreed Basin (L49–53):** Purpose final-region field baseline; entrances Refuge west, Archive east; routes boardwalk ring and shallow channels; combat four islands; monsters EN_R05_S01/S02/S03; elite EN_R05_E01; miniboss none; NPCs NPC_R05_06; quest targets resonance posts, reed choirs; resources luminous reed/comet moss/star iron; landmarks Gleamreed Choir; social pocket Reedlight Enclave; secrets humming hollow; treasure three resonance caches; portals none; dungeon none; event choir convergence; respawn Enclave; safe Enclave; clusters luminous reeds/willow/crystals; depth H0 water/H1 walkways; mobile density 7 enemies, emissive cards ≤16/view; required assets luminous wetland variants, stilt bridges, crystal beetle, enclave, resonance VFX.
- **`MAP_R05_03` Fallen Archive (L52–56):** Purpose lore dungeon/route split; entrances Basin west, Mire east, Refuge skiff; routes causeway and archive galleries; combat five pockets; monsters EN_R05_S03/S04/S05/S06; elite EN_R05_E02; miniboss none; NPCs NPC_R05_07; quest targets tablets, locks, drowned stacks; resources vellum/nightglass/void pearl; landmarks Fallen Archive; social pocket survey camp; secrets submerged index; treasure four lore caches; portals D05; dungeon D05; event memory echo; respawn camp; safe camp/reading room; clusters ruins/shelves/water; depth H0 causeway/H1 galleries; mobile density 7 enemies, text interactables highlighted; required assets archive exterior/interior kit, shelves/tablets, water damage decals, D05 entrance, echo VFX.
- **`MAP_R05_04` Nightglass Mire (L55–58):** Purpose high-threat field and second dungeon; entrances Archive west, Cradle east; routes lantern path and risky glass flats; combat five islands; monsters EN_R05_S02/S05/S07/S08; both elites; miniboss MB_R05_01 meteor basin; NPCs NPC_R05_06 reused; quest targets false lights, shard nests; resources nightglass/void pearl/comet moss; landmarks Nightglass Observatory; social pocket Astral Camp; secrets false-star portal puzzle; treasure miniboss chest +3; portals D06; dungeon D06; event meteor shower; respawn camp; safe camp/observatory; clusters dark water/crystal/reeds; depth H0 mire/H1 observatory; mobile density 7 enemies, bloom and reflections strictly capped; required assets night water, glass flats, observatory, D06 entrance, Cometback, meteor tells, dark-wetland audio.
- **`MAP_R05_05` Starfall Cradle (L58–60):** Purpose final main-story/Mantle/endgame raid threshold; entrances Mire west, RAID03 descent; routes five-Mantle ring and crater spokes; combat four trials/final story arena; monsters EN_R05_S04/S06/S07/S08; elites staged; miniboss MB_R05_01; NPCs NPC_R05_01/NPC_R05_05/NPC_R05_07; quest targets five echoes/cradle seal; resources star iron/nightglass; landmarks Starfall Cradle; social pocket pilgrim ledge; secrets sixth silent socket reserved post-launch and non-interactive; treasure Star Mantle chest; portals RAID03 after main story; dungeon none; event weekly cradle defense; respawn ledge; safe ledge/seal after story; clusters crater/crystal arches/Mantle stones; depth H0 floor/H1 ring/H2 ledge; mobile density 8 staged enemies, boss-size story target only; required assets crater arena, five stones, raid descent, starfall sky/VFX, capstone treasure, performance LODs.

## 4. Original field roster

All IDs are stable. “Family” controls skeleton/animation and production reuse; every named creature still requires its stated silhouette. Standard (`S`) and elite (`E`) totals exclude minibosses (`MB`).

### R01 roster

- `EN_R01_S01` Moorling; MAP_R01_02/03 L1–7; Moorling, standard; squat turquoise reed-frog; curious pack skirmisher; tongue jab/water hop; croak rally; water; reed fiber/Moorling dew; early ecology and nest quests.
- `EN_R01_S02` Honeycap Nibbler; MAP_R01_02/04 L2–9; burrower, standard; round tan digger with honey cap; flees then circles; nibble/dirt pop; steals dropped pollen bundles; earth; soft hide/amber crumb; farm recovery quests.
- `EN_R01_S03` Orchard Grazer; MAP_R01_02/04 L3–10; grazer, standard; long-eared cream quadruped; territorial graze; headbutt/hoof fan; heals near fruit; earth; grazer tuft/fruit seed; orchard balance quests.
- `EN_R01_S04` Reedskip Midge; MAP_R01_03 L4–8; moth, standard; thin-winged amber insect; lateral hover; needle dive/dust cone; evades through reeds; air; wing dust/reed filament; Moorwatch light quests.
- `EN_R01_S05` Muckbud Sprout; MAP_R01_03/05 L5–11; bramble, standard; walking mud bulb; slow ambush; root slap/mud lob; roots in water to armor; earth; mud resin/herb; route-clearing quests.
- `EN_R01_S06` Lantern Newt; MAP_R01_03 L6–9; newt, standard; low salamander with lantern tail; ranged retreat; spark spit/tail sweep; tail reveals secrets when calmed; light; glow gland/clearwater scale; lantern-boardwalk quests.
- `EN_R01_S07` Amberwing Wisp; MAP_R01_04/05 L8–12; wisp, standard; floating leaf-light; orbit caster; amber bolt/ring pulse; links to nearby wisp; light; amber shard/wisp mote; waystone attunement.
- `EN_R01_S08` Hedgeback Tumbler; MAP_R01_04/05 L9–12; bramble, standard; thorny rolling beast; charge-and-rest; roll line/thorn burst; breakable thorn armor; earth; thorn plate/softwood; Mantle trials.
- `EN_R01_E01` Gilded Orchard Grazer; MAP_R01_02/04 L8–11; grazer, elite; bell-antlered gold quadruped; guards herd; antler sweep/hoof shock; rings bell to enrage standards; earth; gilded horn/elite token; elite hunt and Bellhide lead.
- `EN_R01_E02` Old Moor Croaker; MAP_R01_03/05 L9–12; Moorling, elite; broad dark Moorling with reed crown; controls pack; tongue pull/bog splash; summons two Moorlings once; water; elder dew/reed crown; Moorling ecology finale.
- `MB_R01_01` Bellhide Grazer; MAP_R01_04 (quest echo R01_05) L12; grazer, miniboss; massive bell-plated stag-cow; arena charger; triple charge/bell quake/hoof fan; break bells to stop rally; earth/light; Bellhide plate, Mantle sigil, miniboss token; R01 Mantle capstone.

### R02 roster

- `EN_R02_S01` Rootling Forager; MAP_R02_02 L13–17; rootling, standard; small root body/leaf ears; packs around nodes; claw/root toss; burrows at low health; earth; root fiber/resin; boundary ecology.
- `EN_R02_S02` Briarcoil Creeper; MAP_R02_02/04 L14–22; bramble, standard; vine serpent; lane ambush; bite/thorn line; hides in hedge; earth; briar cord/venom sap; route and antidote quests.
- `EN_R02_S03` Mossback Beetle; MAP_R02_02/03 L15–20; beetle, standard; low armored green beetle; frontal tank; horn push/spore shake; rear weak point; earth; shell plate/moss silk; crafting tutorial.
- `EN_R02_S04` Raincap Puffer; MAP_R02_03/05 L17–24; spore, standard; hopping mushroom; area denial; cap slam/spore cloud; changes cloud with rain; nature; raincap/spore sac; ravine cleansing.
- `EN_R02_S05` Barkveil Wisp; MAP_R02_03/04 L18–22; wisp, standard; brown-green masked flame; ranged support; bark dart/ward beam; shields rooted allies; nature; wisp bark/silverleaf; archive research.
- `EN_R02_S06` Ravine Clawer; MAP_R02_03 L19–21; beast, standard; six-legged moss crab; ledge flanker; claw pair/rock spit; wall-scuttle reposition; earth; claw stone/ironbark; lift repair.
- `EN_R02_S07` Thornling Sentry; MAP_R02_04/05 L20–24; rootling, standard; upright spear-root; formation guard; thrust/seed volley; braces against frontal attacks; nature; thorn spear/resin; Warden trials.
- `EN_R02_S08` Moss Guardian Bud; MAP_R02_04/05 L21–24; guardian, standard; compact bark golem; slow protector; fist arc/root cage; awakens near boundary seals; earth; guardian chip/moss core; Mantle seals.
- `EN_R02_E01` Foxglove Rootcaller; MAP_R02_02/04 L19–23; rootling, elite; tall flower-crowned rootling; backline summoner; thorn bolt/root wave; grows healing flowers; nature; foxglove crown/elite token; scout rescue.
- `EN_R02_E02` Mossbell Carapace; MAP_R02_03/04 L20–24; beetle, elite; bell-shelled beetle; terrace defender; ram/bell spores; shell resonance reflects one projectile volley; earth; bell shell/moss silk; ravine elite hunt.
- `MB_R02_01` Crownroot Stag; MAP_R02_04/05 L24; guardian-beast, miniboss; towering root-antler stag; charges between hedge gates; antler rake/root eruption/spore breath; cut three root anchors to expose; nature/earth; Crownroot antler, Mantle sigil, miniboss token; R02 capstone.

### R03 roster

- `EN_R03_S01` Shellskip Crab; MAP_R03_02 L25–29; crab, standard; bright side-walking shell; lateral swarmer; claw snap/sand toss; shell block faces attacker; water; shellstone/claw; strand cleanup.
- `EN_R03_S02` Dune Lantern Moth; MAP_R03_02/04 L26–34; moth, standard; broad saffron wings; hovering harrier; dust beam/wing gust; drawn to active lenses; air/light; wing dust/lens pollen; lens quests.
- `EN_R03_S03` Brinefin Hopper; MAP_R03_02/03 L27–31; glassfin, standard; translucent fish-lizard; water-edge pouncer; fin slash/brine spit; dives through tide pools; water; sunscale/brine gland; tide study.
- `EN_R03_S04` Mirecoil Eel; MAP_R03_03 L29–32; eel, standard; long blue coil with mud fins; hidden ambush; bite/charged water line; conducts brine pools; water/lightning; eel skin/voidless pearl; gauge repair.
- `EN_R03_S05` Saltglass Wisp; MAP_R03_03/04 L30–34; wisp, standard; faceted white-blue light; ranged link; shard bolt/refraction fan; duplicates one false image; light; lens glass/wisp salt; Orrery alignment.
- `EN_R03_S06` Reedjaw Prowler; MAP_R03_03/05 L31–36; beast, standard; lean marsh cat with reed mane; flank hunter; pounce/claw fan; camouflage breaks on attack; nature; reed pelt/sunscale; keeper defense.
- `EN_R03_S07` Tidelens Custodian; MAP_R03_04/05 L32–36; construct, standard; tripod brass-stone lens; patrol caster; beam sweep/body slam; rotates mirror shield; light; lens gear/shellstone; ruin restoration.
- `EN_R03_S08` Foamcrest Skimmer; MAP_R03_04/05 L33–36; ray, standard; hovering white sea-ray; swoop control; wing cut/foam trail; gains speed over water; water/air; foam membrane/brine pearl; beacon trial.
- `EN_R03_E01` Wreckshell Bulwark; MAP_R03_02/04 L31–35; crab, elite; ship-plank armored crab; lane tank; anchor claw/debris cone; break plank armor; water; wreck iron/elite token; salvage hunt.
- `EN_R03_E02` Prismatic Salt Wisp; MAP_R03_03/04 L32–36; wisp, elite; rainbow lens core; beam controller; split beam/prism mines; colors telegraph damage lane; light; prism core/lens glass; Orrery key.
- `MB_R03_01` Saltcrown Matron; MAP_R03_03 (echo R03_05) L36; crab, miniboss; huge crown-shell marsh crab; tide-phase defender; claw sweep/brine geyser/shell roll; tide exposes rear shell locks; water; Saltcrown plate, Mantle sigil, miniboss token; R03 capstone.

### R04 roster

- `EN_R04_S01` Copper Mole; MAP_R04_02 L37–41; copper mole, standard; squat copper-snouted digger; burrow flanker; claw combo/ore spray; surfaces at marked tremor; earth; copper ore/whisker; survey quests.
- `EN_R04_S02` Embercase Beetle; MAP_R04_02/04 L38–46; beetle, standard; glowing cracked shell; slow artillery; horn jab/ember lob; overheats then exposes core; fire; shell slag/emberglass; forge materials.
- `EN_R04_S03` Ashstep Hound; MAP_R04_02/03 L39–43; hound, standard; lean black hound/red paws; pack chaser; bite/ash dash; leaves short ash trail; fire; ash pelt/firebloom; caravan defense.
- `EN_R04_S04` Slagling Drip; MAP_R04_03/05 L40–48; ooze, standard; molten droplet on basalt feet; area denial; slag slap/lava puddle; hardens when cooled; fire/earth; slag core/basalt; vent work.
- `EN_R04_S05` Sootwing Hawk; MAP_R04_03/04 L41–46; bird, standard; angular smoke-wing raptor; dive harrier; talon dive/soot fan; silhouette shadow telegraphs dive; air/fire; soot feather/coal; relay quests.
- `EN_R04_S06` Forge Wisp; MAP_R04_03 L42–44; wisp, standard; ember inside iron ring; support caster; spark bolt/heat link; powers nearby machinery; fire; forge mote/copper wire; machine shutdown.
- `EN_R04_S07` Ventplate Sentry; MAP_R04_04/05 L44–48; construct, standard; broad plated biped; directional guard; shield bash/steam cone; back vent weak point; fire; vent plate/gear; Caldera trials.
- `EN_R04_S08` Cinderhorn Runner; MAP_R04_04/05 L45–48; grazer, standard; agile ram with ember horns; line charger; horn thrust/cinder fan; rebounds from marked walls; fire/earth; cinder horn/scale; Mantle route.
- `EN_R04_E01` Deepvein Copper Mole; MAP_R04_02/04 L43–47; copper mole, elite; plated drill snout; chained burrow attacks; drill rush/ore eruption; tremor sequence creates safe gaps; earth; deep copper/elite token; survey elite.
- `EN_R04_E02` Whitehot Embercase; MAP_R04_03/04 L44–48; beetle, elite; white core/black shell; explosive artillery; triple ember/heat ring; must be cooled at vent valves; fire; whitehot core/emberglass; Foundry key.
- `MB_R04_01` Ashmantle Ram; MAP_R04_04/05 L48; ram, miniboss; enormous basalt mantle and furnace horns; wall-breaking charger; magma charge/hoof fissure/cinder rain; crack mantle against three pillars; fire/earth; Ashmantle horn, Mantle sigil, miniboss token; R04 capstone.

### R05 roster

- `EN_R05_S01` Crystal Beetle; MAP_R05_02 L49–53; crystal beetle, standard; faceted cyan shell; refracting tank; horn jab/shard spray; rotates resistance color; crystal; crystal chip/star iron; resonance study.
- `EN_R05_S02` Gleamreed Shardwing; MAP_R05_02/04 L50–58; moth, standard; narrow luminous glass wings; ranged hover; shard dart/light trail; follows reed-song nodes; light; shard wing/luminous reed; choir quests.
- `EN_R05_S03` Starling Ooze; MAP_R05_02/03 L51–55; ooze, standard; dark blob with star motes; splits and converges; pseudopod/star burst; split halves share health; astral; comet moss/ooze core; contamination quests.
- `EN_R05_S04` Archive Wisp; MAP_R05_03/05 L52–60; ruins wisp, standard; parchment halo; pattern caster; glyph bolt/page wall; repeats last telegraph once; astral; vellum scrap/wisp ink; archive translation.
- `EN_R05_S05` Reed Sentinel; MAP_R05_03/04 L53–58; guardian, standard; stilted reed-and-stone figure; zone defender; pole sweep/root grid; rooted stance resists control; nature; sentinel reed/star iron; causeway restoration.
- `EN_R05_S06` Mireglass Prowler; MAP_R05_03/05 L54–60; beast, standard; black feline with glass spine; stealth flanker; pounce/shard tail; false reflection reveals direction; dark/crystal; nightglass fang/void pearl; tracking quests.
- `EN_R05_S07` Fallen Lens Custodian; MAP_R05_04/05 L56–60; construct, standard; broken floating observatory ring; beam controller; eclipse beam/ring slam; safe wedge rotates visibly; astral; lens segment/star iron; Cradle trials.
- `EN_R05_S08` Cometback Grazer; MAP_R05_04/05 L57–60; grazer, standard; plated marsh grazer with comet tail; aggressive charger; star charge/meteor kick; sheds targetable crystal plates; astral/earth; comet plate/comet moss; Mantle capstone.
- `EN_R05_E01` Choirwing Conductor; MAP_R05_02/04 L55–59; moth, elite; four luminous wings/reed baton tail; synchronizes adds; chord bolts/light lanes; silence reed nodes to interrupt; light; choir wing/elite token; Enclave elite.
- `EN_R05_E02` Nightglass Indexer; MAP_R05_03/04 L56–60; ruins wisp, elite; many-page halo/night core; sequence caster; glyph grid/index beam; attacks follow readable three-symbol order; dark/astral; index seal/nightglass; Archive elite.
- `MB_R05_01` Cometback Behemoth; MAP_R05_04/05 L60; grazer, miniboss; colossal six-plated comet beast; arena breaker; meteor charge/starfall stomp/tail arc; destroy six plates to expose core; astral/earth; Behemoth plate, Mantle sigil, miniboss token; R05 capstone.

## 5. Named NPC roster

Exactly seven stable NPCs per region; `reuse` describes visual production, not narrative identity.

### R01
- `NPC_R01_01` Elian Amberward — Vale keeper/main quest; Ambercross, quest-phase reuse in Hollow; unique mantle coat.
- `NPC_R01_02` Mira Fenwick — merchant; Ambercross; reuse canonical merchant base with amber palette/pack.
- `NPC_R01_03` Ferro Bellows — blacksmith; Ambercross; reuse canonical blacksmith base with copper apron.
- `NPC_R01_04` Sister Linnet — healer/respawn; Ambercross; unique healer head, modular robe.
- `NPC_R01_05` Toma Quill — quest registrar/lore; Ambercross; unique satchel and book.
- `NPC_R01_06` Pella Honeywick — farmer/event host; Honeyglass/Verge; unique straw silhouette.
- `NPC_R01_07` Orrin Reedstep — scout/Mantle guide; Moorwatch/Hollow; unique reed cloak.

### R02
- `NPC_R02_01` Warden Serel — region keeper/main quest; Briarwatch/Crown; unique antler-clasp coat.
- `NPC_R02_02` Nessa Bramblecart — merchant; Briarwatch; merchant-base reuse with woodland packs.
- `NPC_R02_03` Dorn Ironbark — smith; Briarwatch; blacksmith-base reuse with bark guard.
- `NPC_R02_04` Iven Mossmere — herbalist/healer; Briarwatch; unique cap/plant rack.
- `NPC_R02_05` Cael Leafscript — archivist; Briarwatch; unique scroll frame.
- `NPC_R02_06` Rook Foxtrail — pathfinder; Run/Wood; unique short cloak/bow.
- `NPC_R02_07` Maela Bellroot — lift engineer/Mantle guide; Ravine/Crown; unique tool harness.

### R03
- `NPC_R03_01` Harbormaster Solvi — region keeper; Haven/Beacon; unique naval coat.
- `NPC_R03_02` Jori Sunstall — merchant; Haven; merchant-base reuse with coastal awning pack.
- `NPC_R03_03` Kest Tidehammer — smith; Haven; blacksmith-base reuse with shell apron.
- `NPC_R03_04` Anwen Gullrest — fisher/event host; Haven/Strand; unique net silhouette.
- `NPC_R03_05` Lume Arclens — lenskeeper/raid liaison; Haven/Ruins/Beacon; unique lens staff.
- `NPC_R03_06` Rell Drift — salvager; Strand; modular worker with unique hook prop.
- `NPC_R03_07` Sera Brineglass — tide scholar/Mantle guide; Marsh/Ruins; unique glass satchel.

### R04
- `NPC_R04_01` Marshal Varka — region keeper; Cinderward/Gate; unique march armor.
- `NPC_R04_02` Ponn Cinderpack — quartermaster; Cinderward; merchant-base reuse with heat cases.
- `NPC_R04_03` Yara Forgehand — master smith; Cinderward; blacksmith-base reuse with face shield.
- `NPC_R04_04` Emon Ventwise — engineer; Cinderward; unique gauge harness.
- `NPC_R04_05` Tal Ashledger — contracts/event clerk; Cinderward; unique soot ledger.
- `NPC_R04_06` Kiva Redline — surveyor; Steppe/Shelf; unique marker poles.
- `NPC_R04_07` Oren Sootwind — relay tender/Mantle guide; Pass/Gate; unique wind scarf.

### R05
- `NPC_R05_01` Keeper Aster Vale — region/Mantle keeper; Refuge/Cradle; unique five-light mantle.
- `NPC_R05_02` Brin Starbarter — quartermaster; Refuge; merchant-base reuse with star-metal cases.
- `NPC_R05_03` Talli Reedwake — ferrier/event host; Refuge/Basin; unique skiff pole.
- `NPC_R05_04` Doctor Vey — resonance healer; Refuge; unique crystal diagnostic rig.
- `NPC_R05_05` Nima Nightglass — raid liaison; Refuge/Cradle; unique observatory coat.
- `NPC_R05_06` Arlo Choirreed — Enclave guide; Basin/Mire; unique reed instrument.
- `NPC_R05_07` Edda Index — archivist/Mantle guide; Archive/Cradle; unique page halo pack.

## 6. Quest architecture and exact allocation

Quest IDs use `Q_R##_M###`, `Q_R##_S###`, and `Q_R##_R###`. Main chains are sequentially numbered inside each region; side/repeatable IDs remain stable even when unlocked by phase.

| Region | Main | Side | Repeatable | Main arc allocation | Side allocation | Repeatable allocation |
|---|---:|---:|---:|---|---|---|
| R01 | 18 | 12 | 5 | Arrival 4; Honeyglass 3; Moor 3; Verge 3; Mantle/D01 5 | 2 per field map +4 hub/roster | gathering, Moorling ecology, bounty, delivery, event |
| R02 | 18 | 12 | 5 | Briarwatch 3; Run 3; Ravine 3; Wood 4; Mantle/D02 5 | 2 per field map +4 hub/lore | herbs, rootlings, elite, lodge supply, event |
| R03 | 18 | 12 | 5 | Haven 3; Strand 3; Marsh 3; Ruins 4; Mantle/D03 5 | 2 per field map +4 trade/lens | fishing, salvage, elite, ferry, event |
| R04 | 18 | 12 | 5 | Cinderward 3; Steppe 3; Pass 3; Shelf 4; Mantle/D04 5 | 2 per field map +4 forge/relay | mining, vents, elite, convoy, event |
| R05 | 18 | 12 | 5 | Refuge 2; Basin 3; Archive 4; Mire 3; Mantle/D05/D06/finale 6 | 2 per field map +4 archive/endgame | star iron, resonance, elite, archive, event |
| **Launch total** | **90** | **60** | **25** | **90** | **60** | **25** |

- Each regional main arc introduces the hub, opens all five maps, requires its listed dungeon clearance(s), resolves its miniboss, and ends in its Mantle chain. Raids never block cap progression or main-story completion.
- Side quests provide family ecology, settlements, landmarks, secrets, crafting sources, and optional dungeon context; no side quest is silently promoted into main count.
- Repeatables unlock after their first authored side/main version, use daily/weekly caps, and rotate targets without changing the 25 stable quest records.
- Cross-region arc: the five Mantles successively restore road, boundary, tide, mountain, and star-watershed stewardship; `Q_R05_M018` resolves launch canon at cap 60.
- Post-launch quests use a new namespace and are excluded from these totals.

## 7. Environment asset truth, budgets, and status

Status vocabulary: **READY** runtime family exists and is composition-ready; **SOURCE EXISTS** useful source sheet/provenance exists but extraction is required; **PARTIAL** some production assets exist but coverage is incomplete; **REWORK** existing family needs spatial/multi-angle/LOD/semantic correction; **MISSING** no suitable verified family; **NOT REQUIRED** intentionally absent.

Catalog baseline (2026-09-18 audit): ground/road/water/building/portal/entrance and generic combat VFX families exist; elevation and landmarks need adjustment; vegetation has only verified willow/reeds/glow stump/thornberry plus source sheets; canonical monsters cover Moorling, Copper Mole, Crystal Beetle, Lantern Moth, Rootling, Ruins Wisp and partial guardians, but directional locomotion/most attacks are incomplete; merchant and blacksmith directions exist; generic equipment exists but rotation-ready direction/pose coverage is incomplete. Composite masters and collision-loss records are not counted as ready.

Budget codes per map: `G` ground materials (2–4); `P` path modules (4–8); `B` building/hero structures (0–8); `V` vegetation/prop families (4–10); `L` landmarks (1–3); `E` encounter creature families (3–6); `X` generic VFX families (2–5). Counts are family/variant targets, not placed-node counts.

| Map | Budget G/P/B/V/L/E/X | G | P | B | V | L | E | X | Production note |
|---|---|---|---|---|---|---|---|---|---|
| MAP_R01_01 | 3/8/8/8/3/0/3 | READY | READY | READY | PARTIAL | READY | NOT REQUIRED | READY | regional hub assembly/rear-side variants PARTIAL |
| MAP_R01_02 | 3/6/3/9/2/4/3 | READY | READY | PARTIAL | PARTIAL | PARTIAL | PARTIAL | READY | crops/hives/farm rotation variants MISSING |
| MAP_R01_03 | 3/5/1/8/2/5/3 | PARTIAL | PARTIAL | PARTIAL | READY | PARTIAL | PARTIAL | READY | Moorling locomotion REWORK; boardwalk MISSING |
| MAP_R01_04 | 3/6/1/8/3/6/3 | READY | READY | PARTIAL | PARTIAL | REWORK | MISSING | READY | elder tree/miniboss authored families MISSING |
| MAP_R01_05 | 3/5/1/5/3/6/4 | READY | READY | PARTIAL | PARTIAL | REWORK | MISSING | READY | portal/entrance READY; altar/roster MISSING |
| MAP_R02_01 | 3/7/7/9/3/0/3 | PARTIAL | READY | REWORK | SOURCE EXISTS | REWORK | NOT REQUIRED | READY | woodland hub skin and canopy production required |
| MAP_R02_02 | 3/6/1/10/2/4/3 | PARTIAL | READY | PARTIAL | SOURCE EXISTS | REWORK | PARTIAL | READY | Rootling idle exists; other creatures MISSING |
| MAP_R02_03 | 3/5/2/8/3/5/4 | PARTIAL | PARTIAL | MISSING | SOURCE EXISTS | MISSING | MISSING | READY | elevation REWORK; falls/lift/bells MISSING |
| MAP_R02_04 | 3/6/2/10/3/6/4 | PARTIAL | READY | REWORK | SOURCE EXISTS | MISSING | PARTIAL | READY | guardian partial; maze/heart/miniboss MISSING |
| MAP_R02_05 | 3/5/1/6/3/6/4 | PARTIAL | PARTIAL | MISSING | SOURCE EXISTS | MISSING | MISSING | READY | summit/beacon and full roster MISSING |
| MAP_R03_01 | 4/7/8/6/3/0/4 | MISSING | PARTIAL | MISSING | MISSING | MISSING | NOT REQUIRED | READY | water READY; complete coast settlement MISSING |
| MAP_R03_02 | 3/5/1/7/2/4/3 | MISSING | PARTIAL | MISSING | MISSING | MISSING | PARTIAL | READY | Lantern Moth source usable; coast fauna/art MISSING |
| MAP_R03_03 | 4/5/1/8/3/6/5 | MISSING | PARTIAL | MISSING | PARTIAL | MISSING | MISSING | READY | reeds/water partial; tide states/miniboss MISSING |
| MAP_R03_04 | 3/6/1/5/3/6/5 | SOURCE EXISTS | READY | SOURCE EXISTS | MISSING | REWORK | MISSING | READY | ruin sheets exist; lens/raid assembly MISSING |
| MAP_R03_05 | 3/5/2/5/3/6/4 | MISSING | PARTIAL | MISSING | MISSING | MISSING | MISSING | READY | beacon/isle/transition MISSING |
| MAP_R04_01 | 3/7/8/4/3/0/4 | SOURCE EXISTS | READY | SOURCE EXISTS | MISSING | REWORK | NOT REQUIRED | READY | mine sheets exist; basalt fort/forge MISSING |
| MAP_R04_02 | 3/5/1/6/2/4/4 | MISSING | READY | PARTIAL | MISSING | MISSING | PARTIAL | READY | Copper Mole partial; ash biome MISSING |
| MAP_R04_03 | 3/6/2/5/3/5/5 | MISSING | PARTIAL | MISSING | MISSING | MISSING | MISSING | READY | cliffs REWORK; smoke/relay authored work |
| MAP_R04_04 | 4/7/4/4/3/6/5 | SOURCE EXISTS | PARTIAL | SOURCE EXISTS | MISSING | MISSING | PARTIAL | READY | foundry machinery/miniboss MISSING |
| MAP_R04_05 | 3/5/2/3/3/6/5 | MISSING | PARTIAL | MISSING | NOT REQUIRED | MISSING | MISSING | READY | caldera/seal/raid threshold MISSING |
| MAP_R05_01 | 4/7/8/8/3/0/5 | PARTIAL | PARTIAL | MISSING | PARTIAL | MISSING | NOT REQUIRED | READY | wetland sources exist; stilt hub MISSING |
| MAP_R05_02 | 4/5/2/9/2/4/5 | PARTIAL | PARTIAL | MISSING | PARTIAL | MISSING | PARTIAL | READY | Crystal Beetle idle exists; luminous variants MISSING |
| MAP_R05_03 | 4/6/3/5/3/6/5 | SOURCE EXISTS | READY | SOURCE EXISTS | PARTIAL | REWORK | PARTIAL | READY | Ruins Wisp idle exists; archive kit extraction/authorship |
| MAP_R05_04 | 4/5/2/8/3/6/5 | MISSING | PARTIAL | MISSING | PARTIAL | MISSING | MISSING | READY | all nightglass hero families MISSING |
| MAP_R05_05 | 3/6/1/4/3/7/5 | MISSING | READY | MISSING | PARTIAL | MISSING | MISSING | READY | capstone crater, stones, creatures MISSING |

Global shared-family budgets: one eight-direction player body/equipment/attack set; 35 NPC identity kits based on reusable directional bodies; 55 field-creature identity packages; nine instance entrances/portals; five hub service/signage sets; five region sky/fog/color profiles; camera-safe occlusion/fade volumes; low/mid/high LOD or card tiers for large vegetation and hero structures; landscape/portrait composition presets. Reuse generic melee/magic/projectile VFX, but author element color/shape variants without adding persistent overdraw.

## 8. Map production checklist

Apply to every `MAP_R##_0#`; a map cannot move to content-complete until all required items pass.

- [ ] ID, region, level band, entrances, exits, spawn, return shortcut, portal locks, and post-launch dormant content match this masterplan.
- [ ] Graybox validates authoritative X/Z traversal, H0/H1/H2 elevation, collision, navigation links, leash boundaries, and no unreachable resource/treasure.
- [ ] M04.31A composition: one dominant route landmark, separate house/rest/social/forest-edge/combat pockets, authored modular path transitions, planted edges, low clutter, and three readable depth layers.
- [ ] Landscape and portrait framing preserve player, current target, attack tell, retreat lane, and objective; touch UI ownership leaves a safe world-drag zone.
- [ ] Limited-yaw turntable validates all visible building/tree/prop sides inside the allowed camera window; no flat edge, stretched facade, or primitive hero placeholder.
- [ ] Large occluders have camera-aware fade volumes; canopies/roofs do not hide target rings, interactables, drops, or hazards.
- [ ] Standard/elite/miniboss spawn budgets, family mixes, levels, leash rules, respawn cadence, and anti-stack spacing match the roster.
- [ ] Safe/social pockets reject hostile spawns; respawn cannot place players inside hazard, event, elite, or portal triggers.
- [ ] Main/side/repeatable targets, phase states, secret conditions, event takeover rules, resource nodes, and treasure locks have stable IDs.
- [ ] Dungeon/raid/world/event portals communicate locked/open/group status and never overlap navigation or combat.
- [ ] Audio zones, ambient VFX, hazard tells, shadows, transparent layers, particles, lights, draw calls, materials, and texture memory meet mobile budgets on low/mid hardware.
- [ ] Asset manifest audit records each family as READY/SOURCE EXISTS/PARTIAL/REWORK/MISSING/NOT REQUIRED; source sheets and visual masters are never loaded at runtime.
- [ ] Creature and NPC directional coverage is camera-relative; missing directions/locomotion are production gaps, never inferred by mirroring.
- [ ] Multiplayer validation derives presentation from authoritative position/facing while camera yaw remains client-only; crowded hubs retain interaction selection.
- [ ] Accessibility validates color-independent hazard shapes, readable text/icon scale, reduced-flash mode, camera shake control, and audio cue alternatives.
- [ ] Final capture pack includes center/left/right yaw and landscape/portrait for route, landmark, social, combat, hazard, portal, and event states.

## 9. Consistency gates

- Numeric source of truth is the launch contract and the exact-allocation tables, not concept art or post-launch proposals.
- IDs are never recycled. Variants share a family but retain individual enemy IDs; minibosses are not counted among 50 field enemies.
- Dungeons and raids use the names/IDs in the companion PvE masterplan. World maps own only entrances, quest context, and threshold presentation.
- Existing catalog readiness describes fixed-oblique assets, not unrestricted rotation. Every status here is scoped to the locked limited-yaw spatial target.
- Moorling remains canonical in R01 and uses Kit60 direction identity plus Kit70/71 action continuations; Kit21 is vegetation provenance and must never be restored as a creature.
