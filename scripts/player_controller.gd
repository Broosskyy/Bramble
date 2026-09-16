class_name BramblePlayerController
extends CharacterBody2D

@export var move_speed := 250.0
@export var attack_range := 125.0
@export var interact_range := 115.0

@onready var visual: BramblePlayerVisual = $Visual
@onready var equipment_rig: BrambleEquipmentRig = $Visual/EquipmentRig

var attacking := false
var attack_cooldown := 0.0
var net_tick := 0.0
var dash_cooldown := 0.0

func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 2 | 4
	visual.pose_changed.connect(_on_pose)
	visual.animation_finished.connect(_on_animation_finished)
	equipment_rig.set_equipment("leather", true, true, "sword")
	equipment_rig.set_pose("idle_open", false)
	if visual.use_production_assets:
		equipment_rig.visible = false
	var foot := BrambleFootpointSort.new()
	foot.name = "FootpointSort"
	add_child(foot)

func _on_pose(pose: String, left: bool) -> void:
	equipment_rig.set_pose(pose, left)

func _on_animation_finished() -> void:
	if visual.animation == "attack":
		attacking = false

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	net_tick = maxf(0.0, net_tick - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	var input_vec := Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = input_vec * move_speed
	move_and_slide()
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode != "offline" and input_vec.length_squared() > 0.01 and net_tick <= 0.0:
		net_tick = 0.10
		net.send_intent("move", {"direction_x":input_vec.x,"direction_y":input_vec.y})
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0:
		dash_cooldown = 1.15
		if net and net.mode != "offline":net.send_intent("dash", {"direction_x":input_vec.x,"direction_y":input_vec.y})

	if absf(input_vec.x) > 0.05 and not visual.use_production_assets:
		visual.flip_h = input_vec.x < 0.0
	visual.set_facing_from_velocity(input_vec)

	if Input.is_action_just_pressed("basic_attack"):
		basic_attack()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("use_potion"):
		var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
		var potion_net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
		if potion_net and potion_net.mode != "offline":potion_net.send_intent("use_potion", {})
		elif state:state.use_potion()

	if not attacking:
		if input_vec.length_squared() > 0.01:
			visual.set_state("run")
		else:
			visual.set_state("idle")

func basic_attack() -> void:
	if attacking or attack_cooldown > 0.0:
		return
	attacking = true
	attack_cooldown = 0.52
	visual.set_state("attack")

	var nearest: Node2D = null
	var nearest_dist := attack_range
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is Node2D:
			var d := global_position.distance_to(node.global_position)
			if d < nearest_dist:
				nearest = node
				nearest_dist = d
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode != "offline":
		net.send_intent("basic_attack", {})
		if net.mode == "client":return
	if nearest and nearest.has_method("take_damage"):
		nearest.take_damage(14)

func interact() -> void:
	var nearest: Node2D = null
	var nearest_dist := interact_range
	for node in get_tree().get_nodes_in_group("interactable"):
		if node is Node2D:
			var d := global_position.distance_to(node.global_position)
			if d < nearest_dist:
				nearest = node
				nearest_dist = d
	if nearest and nearest.has_method("interact"):
		nearest.interact(self)
	else:
		var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
		if state:
			state.toast_requested.emit("Nichts in Reichweite.")
