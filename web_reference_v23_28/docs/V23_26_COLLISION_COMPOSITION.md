# V23.26 Collision & World Composition

Visual/gameplay direction uses broad genre principles seen in readable anime MMOs:
- clear travel lanes
- dense scenic edges rather than random full-screen clutter
- open combat pockets
- landmarks as navigation anchors
- small foliage remains non-solid
- buildings / major props / trunks / water are solid
- narrow base hitboxes rather than blocking on entire sprite/canopy

Collision:
- player and enemy collision with buildings
- selected major props
- landmark bases
- deterministic grove tree trunks
- river banks
- bridge corridors remain traversable
- dash can no longer pass through solid geometry
- enemy chase/home movement respects world collision
- enemy spawning avoids solid objects and primary travel paths

Composition:
- route network now also reserves physical clearance
- combat/POI pockets are visually opened up
- roadside fences have deliberate gaps
- building/prop grounding shadows added
- nearby POIs receive subtle world labels

This intentionally takes inspiration from the readability principles of classic anime MMORPGs
without copying proprietary maps, assets, UI or exact layouts.
