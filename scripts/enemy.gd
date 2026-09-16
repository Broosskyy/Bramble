class_name BrambleEnemy
extends CharacterBody2D

@export var enemy_id := "monster_sprout"
@export var enemy_name := "Sprössling"
@export var asset_id := "monster_sprout"
@export var use_production_assets := false
@export var production_texture_path := ""
@export var max_hp := 34
@export var move_speed := 85.0
@export var attack_damage := 7
@export var xp_reward := 15
@export var gold_reward := 4
@export var aggro_range := 280.0
@export var attack_range := 58.0
@export var respawn_delay := 8.0
@export var loot_table_id := "moorling_common"

var hp := 34
var spawn_position := Vector2.ZERO
var attack_cooldown := 0.0
var hit_flash := 0.0
var _visual: AnimatedSprite2D
var _sprite_frames: SpriteFrames
var _dir_textures: Dictionary = {}
var _direction := "front"
var _state := "idle"
var _dead := false
var _respawn_timer := 0.0
var _last_attacker: Node = null
var _collision: CollisionShape2D

func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	spawn_position = global_position
	var enemy_authority := get_tree().get_first_node_in_group("enemy_authority_service") as BrambleEnemyAuthorityService
	if enemy_authority:
		enemy_authority.register_enemy(self)
	collision_layer = 2
	collision_mask = 1 | 4

	_collision = CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 22.0
	_collision.shape = shape
	add_child(_collision)

	if use_production_assets and enemy_id == "moorling":
		_setup_moorling_visual()
	else:
		_setup_legacy_visual()

	var foot := BrambleFootpointSort.new()
	foot.name = "FootpointSort"
	foot.foot_offset = Vector2(0, -4)
	add_child(foot)

	var label := Label.new()
	label.name = "Name"
	label.text = enemy_name
	label.position = Vector2(-46, -86)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color("#f4d7bb"))
	label.visible = not use_production_assets
	add_child(label)

	var registry := get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
	if registry:
		registry.register(self)

func is_combat_alive() -> bool:
	return not _dead and hp > 0

func _setup_legacy_visual() -> void:
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = load("res://assets/catalog_legacy/png/%s.png" % asset_id)
	sprite.scale = Vector2.ONE * 0.18
	sprite.position = Vector2(0, -24)
	add_child(sprite)

func _setup_moorling_visual() -> void:
	for dir_name in ["front", "back", "left", "right"]:
		_dir_textures[dir_name] = BrambleWorldPresentationConfig.game_tex("monsters/moorling/directions/kit60_%s.png" % dir_name)
	_visual = AnimatedSprite2D.new()
	_visual.name = "Visual"
	_visual.scale = Vector2.ONE * BrambleWorldPresentationConfig.SCALE_MONSTER_SMALL
	_visual.position = Vector2(0, -78)
	add_child(_visual)
	_sprite_frames = SpriteFrames.new()
	for anim_name in ["idle", "hit", "attack", "defeated"]:
		_sprite_frames.add_animation(anim_name)
		_sprite_frames.set_animation_loop(anim_name, anim_name == "idle")
	_populate_cycle("idle", [
		"monsters/moorling/animations/idle_01/00_idle_01.png",
		"monsters/moorling/animations/idle_02/01_idle_02.png",
		"monsters/moorling/animations/idle_03/02_idle_03.png",
		"monsters/moorling/animations/idle_04/03_idle_04.png"
	], 4.0)
	_populate_cycle("hit", [
		"monsters/moorling/animations/hit_01/00_hit_01.png",
		"monsters/moorling/animations/hit_02/01_hit_02.png",
		"monsters/moorling/animations/hit_03/02_hit_03.png",
		"monsters/moorling/animations/hit_04/03_hit_04.png"
	], 10.0)
	_populate_cycle("attack", [
		"monsters/moorling/animations/attack_01/04_attack_01.png",
		"monsters/moorling/animations/attack_02/05_attack_02.png",
		"monsters/moorling/animations/attack_03/06_attack_03.png",
		"monsters/moorling/animations/attack_04/07_attack_04.png"
	], 9.0)
	_populate_cycle("defeated", [
		"monsters/moorling/animations/defeated_01/04_defeated_01.png",
		"monsters/moorling/animations/defeated_02/05_defeated_02.png",
		"monsters/moorling/animations/defeated_03/06_defeated_03.png",
		"monsters/moorling/animations/defeated_04/07_defeated_04.png"
	], 6.0)
	_visual.sprite_frames = _sprite_frames
	_apply_direction("front")
	_visual.play("idle")

func _populate_cycle(anim: String, paths: Array, fps: float) -> void:
	_sprite_frames.set_animation_speed(anim, fps)
	for rel in paths:
		var tex := BrambleWorldPresentationConfig.game_tex(rel)
		if tex:
			_sprite_frames.add_frame(anim, tex)

func _apply_direction(dir: String) -> void:
	_direction = dir
	var tex: Texture2D = _dir_textures.get(dir, _dir_textures.get("front"))
	if tex == null or _visual == null:
		return
	if _state == "idle":
		_sprite_frames.clear("idle")
		_sprite_frames.add_frame("idle", tex)
		_visual.play("idle")

func _set_presentation_state(next: String) -> void:
	if _visual == null or not _sprite_frames.has_animation(next):
		return
	_state = next
	_visual.play(next)

func _physics_process(delta: float) -> void:
	if _dead:
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_respawn()
		return

	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode == "client":
		return

	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)

	if _visual:
		_visual.modulate = Color(1.5, 1.5, 1.5, 1.0) if hit_flash > 0.0 else Color.WHITE
	elif has_node("Sprite"):
		var sprite := get_node("Sprite") as Sprite2D
		sprite.modulate = Color(1.5, 1.5, 1.5, 1.0) if hit_flash > 0.0 else Color.WHITE

	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		return

	var game_state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if game_state and game_state.is_dead:
		velocity = Vector2.ZERO
		return

	var d := global_position.distance_to(player.global_position)
	var enemy_authority := get_tree().get_first_node_in_group("enemy_authority_service") as BrambleEnemyAuthorityService

	if d <= aggro_range:
		if enemy_authority:
			enemy_authority.set_state(self, "chase" if d > attack_range else "attack", multiplayer.get_unique_id())
		if _visual:
			var dir := _vector_to_direction(global_position.direction_to(player.global_position))
			_apply_direction(dir)
		if d > attack_range:
			var desired := global_position.direction_to(player.global_position) * move_speed
			velocity = _slide_with_collision(desired)
			if _visual and _state != "hit":
				_set_presentation_state("idle")
		else:
			velocity = Vector2.ZERO
			if attack_cooldown <= 0.0 and (enemy_authority == null or enemy_authority.can_attack(self, 1.15)):
				attack_cooldown = 1.15
				if _visual:
					_set_presentation_state("attack")
				var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
				if net and net.mode == "host" and pa:
					pa.damage(multiplayer.get_unique_id(), attack_damage)
					if game_state:
						game_state.damage_player(attack_damage)
						var visual := player.get_node_or_null("Visual") as BramblePlayerVisual
						if visual:
							visual.play_hit()
				elif game_state:
					game_state.damage_player(attack_damage)
					var visual := player.get_node_or_null("Visual") as BramblePlayerVisual
					if visual:
						visual.play_hit()
	else:
		if enemy_authority:
			enemy_authority.set_state(self, "return")
		var home_dist := global_position.distance_to(spawn_position)
		if home_dist > 14.0:
			var desired := global_position.direction_to(spawn_position) * move_speed * 0.55
			velocity = _slide_with_collision(desired)
			if _visual and _state != "hit":
				_apply_direction(_vector_to_direction(velocity))
				_set_presentation_state("idle")
		else:
			velocity = Vector2.ZERO
			if _visual and _state != "hit" and _state != "attack":
				_set_presentation_state("idle")

func _slide_with_collision(desired: Vector2) -> Vector2:
	velocity = desired
	move_and_slide()
	return velocity

func _vector_to_direction(v: Vector2) -> String:
	if v.length_squared() <= 0.02:
		return _direction
	var angle := v.angle()
	var quad := int(round(angle / (TAU / 4.0))) % 4
	var mapping := ["right", "front", "left", "back"]
	return mapping[quad]

func take_damage(amount: int, attacker: Node = null) -> void:
	if _dead:
		return
	if attacker:
		_last_attacker = attacker
	hp -= amount
	hit_flash = 0.10
	if _visual:
		_set_presentation_state("hit")
	if hp <= 0:
		_die()

func _exit_tree() -> void:
	var enemy_authority := get_tree().get_first_node_in_group("enemy_authority_service") as BrambleEnemyAuthorityService
	if enemy_authority:
		enemy_authority.unregister_enemy(self)
	var registry := get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
	if registry:
		registry.unregister(self)

func _die() -> void:
	if _dead:
		return
	_dead = true
	_state = "dead"
	velocity = Vector2.ZERO
	if _visual:
		_set_presentation_state("defeated")
	var runtime = get_tree().get_first_node_in_group("combat_runtime_service")
	if runtime and runtime.has_method("handle_enemy_death"):
		runtime.handle_enemy_death(self, _last_attacker)
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	if targeting and targeting.has_method("get_target") and targeting.get_target() == self:
		if targeting.has_method("clear_target"):
			targeting.clear_target()
	visible = false
	if _collision:
		_collision.disabled = true
	_respawn_timer = respawn_delay

func _respawn() -> void:
	_dead = false
	_state = "idle"
	hp = max_hp
	global_position = spawn_position
	visible = true
	if _collision:
		_collision.disabled = false
	if _visual:
		_apply_direction("front")
		_set_presentation_state("idle")
