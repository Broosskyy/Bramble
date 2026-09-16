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
var combat_blocked := false

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
	var registry := get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
	if registry:
		registry.register(self, 1)
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state:
		state.player_died.connect(_on_player_died)
		state.player_recovered.connect(_on_player_recovered)

func _on_player_died() -> void:
	combat_blocked = true
	attacking = false
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	if targeting:
		targeting.clear_target()

func _on_player_recovered() -> void:
	combat_blocked = false

func _on_pose(pose: String, left: bool) -> void:
	equipment_rig.set_pose(pose, left)

func _on_animation_finished() -> void:
	if visual.animation == "attack":
		attacking = false

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	net_tick = maxf(0.0, net_tick - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)

	var input_vec := Vector2.ZERO
	if not combat_blocked:
		input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vec * move_speed
	move_and_slide()

	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode != "offline" and input_vec.length_squared() > 0.01 and net_tick <= 0.0:
		net_tick = 0.10
		net.send_intent("move", {"direction_x": input_vec.x, "direction_y": input_vec.y})
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0 and not combat_blocked:
		dash_cooldown = 1.15
		if net and net.mode != "offline":
			net.send_intent("dash", {"direction_x": input_vec.x, "direction_y": input_vec.y})

	if absf(input_vec.x) > 0.05 and not visual.use_production_assets:
		visual.flip_h = input_vec.x < 0.0
	visual.set_facing_from_velocity(input_vec)

	if not combat_blocked:
		if Input.is_action_just_pressed("basic_attack"):
			basic_attack()
		if Input.is_action_just_pressed("skill_1"):
			use_skill(0)
		if Input.is_action_just_pressed("interact"):
			interact()
		if Input.is_action_just_pressed("use_potion"):
			var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
			var potion_net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
			if potion_net and potion_net.mode != "offline":
				potion_net.send_intent("use_potion", {})
			elif state:
				state.use_potion()

	_sync_authority_position(net)

	if not attacking and not combat_blocked:
		if input_vec.length_squared() > 0.01:
			visual.set_state("run")
		else:
			visual.set_state("idle")

func _sync_authority_position(net: BrambleNetworkSession) -> void:
	if net == null or net.mode == "offline":
		return
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if pa == null:
		return
	var peer_id := multiplayer.get_unique_id()
	var s := pa.ensure_peer(peer_id, {
		"x": global_position.x,
		"y": global_position.y,
		"dir_x": velocity.x,
	})
	s["x"] = global_position.x
	s["y"] = global_position.y
	s["dir_x"] = velocity.x

func basic_attack() -> void:
	if attacking or attack_cooldown > 0.0 or combat_blocked:
		return
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	var target_id: int = targeting.get_target_entity_id() if targeting else 0
	attacking = true
	attack_cooldown = 0.52
	visual.set_state("attack")
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode != "offline":
		net.send_intent("basic_attack", {"target_entity_id": target_id})
		if net.mode == "client":
			return
	var runtime = get_tree().get_first_node_in_group("combat_runtime_service")
	if runtime:
		runtime.resolve_basic_attack(self, target_id)

func use_skill(slot: int) -> void:
	if attacking or combat_blocked:
		return
	var runtime = get_tree().get_first_node_in_group("combat_runtime_service")
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if runtime and not runtime.skill_ready(slot) and (net == null or net.mode == "offline"):
		return
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	var target_id: int = targeting.get_target_entity_id() if targeting else 0
	attacking = true
	visual.set_state("attack")
	if net and net.mode != "offline":
		net.send_intent("skill", {"slot": slot, "target_entity_id": target_id})
		if net.mode == "client":
			return
	if runtime:
		runtime.resolve_skill(self, slot, target_id)

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
