class_name BrambleVillageBuilder
extends Node2D

const CAT := "res://assets/catalog_legacy/png/"

@onready var ground: Node2D = $Ground
@onready var roads: Node2D = $Roads
@onready var objects: Node2D = $WorldObjects
@onready var npcs: Node2D = $NPCs
@onready var monsters: Node2D = $Monsters
@onready var collisions: Node2D = $Collisions
@onready var portals: Node2D = $Portals

func _ready() -> void:
	_build_ground()
	_build_roads()
	_build_village()
	_build_npcs()
	_build_enemies()
	_build_portals()

func _tex(id: String) -> Texture2D:
	return load(CAT + id + ".png") as Texture2D

func _sprite(parent: Node, id: String, pos: Vector2, scale_value: float, z := 0) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = _tex(id)
	sp.position = pos
	sp.scale = Vector2.ONE * scale_value
	sp.z_index = z
	parent.add_child(sp)
	return sp

func _label(parent: Node, text: String, pos: Vector2, color := Color("#fff0c8"), size := 18) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.z_index = 50
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.9))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func _solid_rect(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 4
	body.collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	collisions.add_child(body)

func _solid_circle(pos: Vector2, radius: float) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 4
	body.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	body.add_child(shape)
	collisions.add_child(body)

func _build_ground() -> void:
	var sc := 0.80
	var step := 322.0
	for y in range(-3, 4):
		for x in range(-5, 6):
			var id := "terrain_meadow"
			if (x + y) % 5 == 0:
				id = "terrain_meadow_wildflowers"
			elif (x * 3 + y) % 7 == 0:
				id = "terrain_flower_meadow"
			_sprite(ground, id, Vector2(x*step,y*step), sc, -20)

func _build_roads() -> void:
	var sc := 0.56
	for y in [-760.0,-520.0,-280.0,-40.0,200.0,440.0,680.0]:
		_sprite(roads,"path_cobble_vertical",Vector2(0,y),sc,-10)
	for x in [-720.0,-480.0,-240.0,0.0,240.0,480.0,720.0]:
		_sprite(roads,"path_horizontal",Vector2(x,120),sc,-9)
	_sprite(roads,"path_cross",Vector2(0,120),sc,-8)

func _building(id: String, pos: Vector2, scale_value: float, collision_size: Vector2, title: String) -> void:
	_sprite(objects,id,pos,scale_value,int(pos.y))
	_solid_rect(pos+Vector2(0,48),collision_size)
	_label(objects,title,pos+Vector2(-70,-150),Color("#ffe6a0"),16)

func _tree(id: String, pos: Vector2, scale_value := 0.42) -> void:
	_sprite(objects,id,pos,scale_value,int(pos.y))
	_solid_circle(pos+Vector2(0,55),28)

func _prop(id: String, pos: Vector2, scale_value := 0.32) -> void:
	_sprite(objects,id,pos,scale_value,int(pos.y))

func _build_village() -> void:
	_building("building_inn",Vector2(-610,-300),0.42,Vector2(160,110),"Mondblatt-Taverne")
	_building("building_smithy",Vector2(610,-310),0.42,Vector2(170,115),"Ferro · Schmiede")
	_building("building_guildhall",Vector2(-640,520),0.44,Vector2(185,120),"Gildenhalle")
	_building("building_cottage",Vector2(620,500),0.40,Vector2(155,105),"Wohnhaus")
	_building("building_shrine",Vector2(0,-720),0.37,Vector2(120,90),"Waldschrein")
	_prop("prop_fountain",Vector2(0,120),0.35)
	_prop("prop_notice_board",Vector2(-290,160),0.32)
	_prop("prop_well",Vector2(300,160),0.30)
	_prop("prop_cart",Vector2(-470,100),0.30)
	_prop("prop_signpost",Vector2(500,130),0.28)
	_prop("prop_bench",Vector2(210,330),0.28)
	_prop("prop_crates",Vector2(480,-180),0.25)
	_prop("prop_barrel",Vector2(530,-170),0.20)
	_prop("prop_chest_closed",Vector2(-820,720),0.24)
	for e in [
		["tree_oak_green",Vector2(-1160,-760)],["tree_birch",Vector2(-920,-770)],
		["tree_cherry",Vector2(-1190,-250)],["tree_oak_green",Vector2(-1110,280)],
		["tree_birch",Vector2(-1050,760)],["tree_ancient",Vector2(1050,-720)],
		["tree_oak_green",Vector2(1180,-260)],["tree_cherry",Vector2(1110,260)],
		["tree_birch",Vector2(1030,760)],["tree_oak_green",Vector2(760,860)],
		["tree_cherry",Vector2(-700,870)],["tree_sapling",Vector2(870,610)]
	]:
		_tree(e[0],e[1])
	for p in [Vector2(-360,-530),Vector2(350,-540),Vector2(-420,390),Vector2(410,390),Vector2(-850,20),Vector2(840,30)]:
		_sprite(objects,"plant_wildflowers",p,0.22,int(p.y)-1)

func _add_npc(id: String, asset: String, name_text: String, role_text: String, pos: Vector2) -> void:
	var n := BrambleNpc.new()
	n.npc_id = id
	n.asset_id = asset
	n.npc_name = name_text
	n.npc_role = role_text
	n.position = pos
	n.z_index = int(pos.y)
	npcs.add_child(n)

func _build_npcs() -> void:
	_add_npc("lina","npc_healer","Lina","Questgeberin",Vector2(-120,-500))
	_add_npc("ferro","npc_blacksmith","Ferro","Schmied",Vector2(500,-90))
	_add_npc("lia","npc_merchant","Lia","Händlerin",Vector2(-350,40))
	_add_npc("rovan","npc_guard","Rovan","Wache",Vector2(580,250))
	_add_npc("bram","npc_bard","Bram","Barde",Vector2(-190,330))
	_add_npc("nela","npc_baker","Nela","Bäckerin",Vector2(-510,-80))

func _add_enemy(id: String, name_text: String, pos: Vector2, hp: int, dmg: int, xp: int, gold: int, speed := 85.0) -> void:
	var e := BrambleEnemy.new()
	e.enemy_id = id
	e.asset_id = id
	e.enemy_name = name_text
	e.max_hp = hp
	e.attack_damage = dmg
	e.xp_reward = xp
	e.gold_reward = gold
	e.move_speed = speed
	e.position = pos
	e.z_index = int(pos.y)
	monsters.add_child(e)

func _build_enemies() -> void:
	_label(monsters,"ÖSTLICHE FELDER · LV 1–6",Vector2(820,-920),Color("#e8cf85"),18)
	_add_enemy("monster_sprout","Sprössling",Vector2(900,-720),30,6,14,4,78)
	_add_enemy("monster_sprout","Sprössling",Vector2(1080,-650),30,6,14,4,78)
	_add_enemy("monster_sprout","Sprössling",Vector2(1200,-540),30,6,14,4,78)
	_add_enemy("monster_hornhare","Hornhase",Vector2(1060,-410),38,7,17,5,105)
	_add_enemy("monster_mushroom","Pilzling",Vector2(1220,-280),42,8,19,5,70)
	_add_enemy("monster_hedgehog","Bramigel",Vector2(1010,-90),52,9,22,6,62)
	_add_enemy("monster_beetle","Eichelkäfer",Vector2(1210,120),58,10,25,7,58)
	_add_enemy("monster_wolf","Dämmerwolf",Vector2(1080,340),72,12,31,9,118)
	_add_enemy("monster_boar","Waldkeiler",Vector2(1230,560),82,13,36,10,90)

func _build_portals() -> void:
	var p := BramblePortal.new()
	p.portal_name = "Östliche Felder"
	p.destination = Vector2(900,-650)
	p.position = Vector2(760,-40)
	portals.add_child(p)

	var h := BramblePortal.new()
	h.portal_name = "Hainweiler Zentrum"
	h.destination = Vector2(0,360)
	h.position = Vector2(860,-650)
	portals.add_child(h)
