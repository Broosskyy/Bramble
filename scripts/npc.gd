class_name BrambleNpc
extends Node2D

@export var npc_id := ""
@export var npc_name := "NPC"
@export var npc_role := ""
@export var asset_id := "npc_merchant"
@export var use_production_assets := false
@export var production_texture_path := ""

var _pulse := 0.0

func _ready() -> void:
	add_to_group("interactable")
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	if use_production_assets and production_texture_path != "":
		sprite.texture = BrambleWorldPresentationConfig.game_tex(production_texture_path)
		sprite.scale = Vector2.ONE * BrambleWorldPresentationConfig.NPC_SCALE
		sprite.position = Vector2(0, -62)
	else:
		sprite.texture = load("res://assets/catalog_legacy/png/%s.png" % asset_id)
		sprite.scale = Vector2.ONE * 0.20
		sprite.position = Vector2(0, -28)
	add_child(sprite)
	var foot := BrambleFootpointSort.new()
	foot.name = "FootpointSort"
	foot.foot_offset = Vector2(0, 0 if use_production_assets else -8)
	add_child(foot)
	z_index = BrambleWorldPresentationConfig.sort_key(position.y, 0)

	var name_label := Label.new()
	name_label.name = "Name"
	name_label.text = npc_name
	name_label.position = Vector2(-48, -120)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color("#fff1bd"))
	add_child(name_label)

	var role_label := Label.new()
	role_label.text = npc_role
	role_label.position = Vector2(-45, -98)
	role_label.add_theme_font_size_override("font_size", 11)
	role_label.add_theme_color_override("font_color", Color("#b9d9aa"))
	add_child(role_label)

	if npc_id == "lina":
		var quest := Label.new()
		quest.name = "QuestMarker"
		quest.text = "!"
		quest.position = Vector2(-7, -154)
		quest.add_theme_font_size_override("font_size", 27)
		quest.add_theme_color_override("font_color", Color("#ffd35a"))
		add_child(quest)

func _process(delta: float) -> void:
	_pulse += delta
	var q := get_node_or_null("QuestMarker")
	if q:
		q.scale = Vector2.ONE * (1.0 + sin(_pulse * 4.0) * 0.08)

func interact(_player: Node) -> void:
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state == null:
		return
	var text := state.talk_to_npc(npc_id, npc_name)
	var hud := get_tree().get_first_node_in_group("production_hud")
	if hud == null:
		hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_dialogue"):
		hud.show_dialogue(npc_name, text)
