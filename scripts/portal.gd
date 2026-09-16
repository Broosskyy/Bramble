class_name BramblePortal
extends Node2D

@export var portal_name := "Östliche Felder"
@export var destination := Vector2(900, -700)

func _ready() -> void:
	add_to_group("interactable")
	var ring := Sprite2D.new()
	ring.texture = load("res://assets/catalog_legacy/png/prop_signpost.png")
	ring.scale = Vector2.ONE * 0.25
	add_child(ring)

	var label := Label.new()
	label.text = "→ " + portal_name
	label.position = Vector2(-72, -72)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("#f5d98e"))
	add_child(label)

func interact(player: Node) -> void:
	if player is Node2D:
		player.global_position = destination
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state:
		state.toast_requested.emit("Gebiet: %s" % portal_name)
