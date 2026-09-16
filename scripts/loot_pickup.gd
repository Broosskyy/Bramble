class_name BrambleLootPickup
extends Area2D

@export var gold_amount := 4
@export var item_id := ""
var life := 18.0

func _ready() -> void:
	add_to_group("loot")
	collision_layer = 4
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 20.0
	shape.shape = circle
	add_child(shape)

	var sprite := Sprite2D.new()
	if item_id == "herb":
		sprite.texture = load("res://assets/catalog_legacy/png/prop_herb_bundle.png") if ResourceLoader.exists("res://assets/catalog_legacy/png/prop_herb_bundle.png") else load("res://assets/catalog_legacy/png/prop_chest_closed.png")
	elif item_id == "ore":
		sprite.texture = load("res://assets/catalog_legacy/png/prop_ore_chunk.png") if ResourceLoader.exists("res://assets/catalog_legacy/png/prop_ore_chunk.png") else load("res://assets/catalog_legacy/png/prop_chest_closed.png")
	else:
		sprite.texture = load("res://assets/catalog_legacy/png/prop_chest_closed.png")
	sprite.scale = Vector2.ONE * 0.09
	add_child(sprite)
	body_entered.connect(_on_body)
	input_event.connect(_on_input_event)

func _process(delta: float) -> void:
	life -= delta
	rotation = sin(Time.get_ticks_msec() / 300.0) * 0.04
	if life <= 0.0:
		queue_free()

func _on_body(body: Node) -> void:
	if body.is_in_group("player"):
		pickup(body)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		var player := get_tree().get_first_node_in_group("player")
		if player:
			pickup(player)

func pickup(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state == null:
		queue_free()
		return
	if item_id != "":
		state.add_inventory_item(item_id)
		state.toast_requested.emit("+%s" % item_id)
	if gold_amount > 0:
		state.gold += gold_amount
		state.player_stats_changed.emit(state.hp, state.max_hp, state.level, state.xp, state.gold)
		state.toast_requested.emit("+%d Gold" % gold_amount)
	queue_free()
