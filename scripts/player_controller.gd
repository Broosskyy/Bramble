class_name BramblePlayerController
extends CharacterBody2D

# Exact Harvest World locomotion tuning from Kein Name.
@export var move_speed := 500.0
@export var move_acceleration := 3300.0
@export var move_deceleration := 4900.0
@export var turn_acceleration := 6200.0
@export var dash_speed := 1750.0
@export var dash_duration := 0.21
@export var attack_range := 125.0
@export var interact_range := 115.0
@export var auto_combat_enabled := true
@export var attack_interval := 0.52
@export var attack_lock_duration := 0.24

@onready var visual: BramblePlayerVisual = $Visual
@onready var equipment_rig: BrambleEquipmentRig = $Visual/EquipmentRig

var attacking := false
var attack_cooldown := 0.0
var net_tick := 0.0
var dash_cooldown := 0.0
var combat_blocked := false
var _virtual_move_vector := Vector2.ZERO
var _attack_lock_remaining := 0.0
var _dash_remaining := 0.0
var _dash_direction := Vector2.DOWN

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
	_attack_lock_remaining = 0.0
	_virtual_move_vector = Vector2.ZERO
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
	_attack_lock_remaining = maxf(0.0, _attack_lock_remaining - delta)
	if attacking and _attack_lock_remaining <= 0.0:
		attacking = false
	net_tick = maxf(0.0, net_tick - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	var was_dashing := _dash_remaining > 0.0
	_dash_remaining = maxf(0.0, _dash_remaining - delta)

	var manual_input := Vector2.ZERO
	if not combat_blocked:
		manual_input = _camera_relative_input(_combined_move_input())
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0 and not combat_blocked:
		dash_cooldown = 1.45
		_dash_remaining = dash_duration
		_dash_direction = manual_input.normalized() if manual_input.length_squared() > 0.0004 else _dash_direction
	var input_vec := manual_input
	var combat_target := _current_combat_target()
	var combat_direction := Vector2.ZERO
	var combat_distance := INF
	# Kein Name field combat never hijacks locomotion. Selecting an enemy and
	# starting the attack chain does not auto-walk the Hero into range.
	if _dash_remaining > 0.0:
		var progress := 1.0 - (_dash_remaining / maxf(0.001, dash_duration))
		var dash_now := dash_speed * (1.0 - progress * 0.28)
		velocity = _dash_direction * dash_now
	else:
		if was_dashing:
			# Match Kein Name: retain 58% locomotion velocity when the dash ends
			# instead of snapping straight into the next input sample.
			velocity = _dash_direction * move_speed * 0.58
		var target_velocity := input_vec * move_speed
		var current_speed := velocity.length()
		var target_speed := target_velocity.length()
		var braking := input_vec.length_squared() <= 0.0004 or target_speed < current_speed * 0.55
		var rate := move_acceleration
		if braking:
			rate = move_deceleration
		elif current_speed > 1.0 and target_speed > 1.0 and velocity.normalized().dot(target_velocity.normalized()) < 0.25:
			rate = turn_acceleration
		velocity = velocity.move_toward(target_velocity, rate * delta)
		if input_vec.length_squared() <= 0.0004 and velocity.length() < 2.0:
			velocity = Vector2.ZERO
	move_and_slide()
	_clamp_to_playable_world()

	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode != "offline" and input_vec.length_squared() > 0.01 and net_tick <= 0.0:
		net_tick = 0.10
		net.send_intent("move", {"direction_x": input_vec.x, "direction_y": input_vec.y})
	if _dash_remaining > 0.0 and net and net.mode != "offline":
		net.send_intent("dash", {"direction_x": _dash_direction.x, "direction_y": _dash_direction.y})

	var facing_vec := velocity.normalized() if velocity.length_squared() > 4.0 else input_vec
	if combat_target and manual_input.length_squared() <= 0.0004 and _dash_remaining <= 0.0:
		combat_direction = global_position.direction_to(combat_target.global_position)
		facing_vec = combat_direction
	if absf(facing_vec.x) > 0.05 and not visual.use_production_assets:
		visual.flip_h = facing_vec.x < 0.0
	visual.set_facing_from_velocity(facing_vec)

	if not combat_blocked:
		if Input.is_action_just_pressed("basic_attack"):
			var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
			if targeting and targeting.has_method("toggle_auto_attack"):
				var result: String = targeting.toggle_auto_attack()
				if result == "no_target":
					var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
					if state:
						state.toast_requested.emit("Erst einen Gegner auswählen.")
			else:
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

	if not combat_blocked and auto_combat_enabled and combat_target:
		var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
		var chain_active := targeting != null and targeting.has_method("is_auto_attack_active") and targeting.is_auto_attack_active()
		if chain_active:
			combat_distance = global_position.distance_to(combat_target.global_position)
			if combat_distance <= attack_range and attack_cooldown <= 0.0 and not attacking:
				basic_attack()

	_sync_authority_position(net)

	if not attacking and not combat_blocked:
		if input_vec.length_squared() > 0.01:
			visual.set_state("run")
		else:
			visual.set_state("idle")

func set_virtual_move_vector(value: Vector2) -> void:
	# Mobile HUD feeds a true analogue vector here. Keeping this separate from
	# InputMap avoids synthetic key states getting stuck across touch/layout events.
	var v := value
	if v.length() > 1.0:
		v = v.normalized()
	_virtual_move_vector = Vector2.ZERO if v.length_squared() < 0.0004 else v

func clear_virtual_move_vector() -> void:
	_virtual_move_vector = Vector2.ZERO

func _combined_move_input() -> Vector2:
	var hardware := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Hardware input wins for desktop/dev testing. Mobile remains fully analogue.
	if hardware.length_squared() > 0.0004:
		return hardware
	return _virtual_move_vector

func _camera_relative_input(screen_input: Vector2) -> Vector2:
	var hybrid = get_tree().get_first_node_in_group("hybrid_world_3d")
	if hybrid and hybrid.has_method("is_active") and hybrid.is_active() and hybrid.has_method("camera_relative_move"):
		return hybrid.camera_relative_move(screen_input)
	return screen_input

func _clamp_to_playable_world() -> void:
	# Camera limits alone do not stop a CharacterBody2D from leaving the authored
	# world. A small inset keeps the player/collision capsule visible at the edge.
	var bounds := BrambleWorldPresentationConfig.WORLD_MAP_BOUNDS.grow(-24.0)
	global_position.x = clampf(global_position.x, bounds.position.x, bounds.end.x)
	global_position.y = clampf(global_position.y, bounds.position.y, bounds.end.y)

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
	var target: Node2D = targeting.get_target() if targeting and targeting.has_method("get_target") else null
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("is_combat_alive") and not target.is_combat_alive():
		if targeting:
			targeting.clear_target()
		return
	var distance := global_position.distance_to(target.global_position)
	if distance > attack_range:
		# Keeping the selected target lets the Kein-Name auto-approach take over
		# on the next physics frame instead of wasting an attack into empty space.
		return
	visual.set_facing_from_velocity(global_position.direction_to(target.global_position))
	var target_id: int = targeting.get_target_entity_id() if targeting else 0
	attacking = true
	attack_cooldown = attack_interval
	_attack_lock_remaining = attack_lock_duration
	visual.set_state("attack")
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode != "offline":
		net.send_intent("basic_attack", {"target_entity_id": target_id})
		if net.mode == "client":
			return
	var runtime = get_tree().get_first_node_in_group("combat_runtime_service")
	if runtime:
		runtime.resolve_basic_attack(self, target_id)

func _current_combat_target() -> Node2D:
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	if targeting == null or not targeting.has_method("get_target"):
		return null
	var target: Node2D = targeting.get_target()
	if target == null or not is_instance_valid(target):
		return null
	if target.has_method("is_combat_alive") and not target.is_combat_alive():
		return null
	return target

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
