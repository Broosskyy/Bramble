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

var hp := 34
var spawn_position := Vector2.ZERO
var attack_cooldown := 0.0
var hit_flash := 0.0
var _visual: AnimatedSprite2D
var _sprite_frames: SpriteFrames
var _dir_textures: Dictionary = {}
var _direction := "front"
var _state := "idle"

func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	spawn_position = global_position
	var enemy_authority:=get_tree().get_first_node_in_group("enemy_authority_service") as BrambleEnemyAuthorityService
	if enemy_authority:enemy_authority.register_enemy(self)
	collision_layer = 2
	collision_mask = 1

	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 22.0
	collider.shape = shape
	add_child(collider)

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

	var hp_back := ColorRect.new()
	hp_back.name = "HpBack"
	hp_back.position = Vector2(-36, -68)
	hp_back.size = Vector2(72, 7)
	hp_back.color = Color(0.05,0.05,0.05,0.8)
	hp_back.visible = false
	add_child(hp_back)

	var hp_fill := ColorRect.new()
	hp_fill.name = "HpFill"
	hp_fill.position = Vector2(-34, -66)
	hp_fill.size = Vector2(68, 3)
	hp_fill.color = Color("#d35e51")
	hp_fill.visible = false
	add_child(hp_fill)

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
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode == "client":return
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)

	if _visual:
		_visual.modulate = Color(1.5,1.5,1.5,1.0) if hit_flash > 0.0 else Color.WHITE
	elif has_node("Sprite"):
		var sprite := get_node("Sprite") as Sprite2D
		sprite.modulate = Color(1.5,1.5,1.5,1.0) if hit_flash > 0.0 else Color.WHITE

	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		return

	var d := global_position.distance_to(player.global_position)
	var hp_back := get_node_or_null("HpBack") as CanvasItem
	var hp_fill := get_node_or_null("HpFill") as CanvasItem
	if use_production_assets and hp_back and hp_fill:
		var targeted := d <= aggro_range * 0.65
		var in_combat := d <= aggro_range or hp < max_hp
		var show_hp := targeted or in_combat
		hp_back.visible = show_hp
		hp_fill.visible = show_hp

	var enemy_authority:=get_tree().get_first_node_in_group("enemy_authority_service") as BrambleEnemyAuthorityService
	if d <= aggro_range:
		if enemy_authority:enemy_authority.set_state(self,"chase" if d > attack_range else "attack",multiplayer.get_unique_id())
		if _visual:
			var dir := _vector_to_direction(global_position.direction_to(player.global_position))
			_apply_direction(dir)
		if d > attack_range:
			velocity = global_position.direction_to(player.global_position) * move_speed
			move_and_slide()
			if _visual and _state != "hit":
				_set_presentation_state("idle")
		else:
			velocity = Vector2.ZERO
			if attack_cooldown <= 0.0 and (enemy_authority==null or enemy_authority.can_attack(self,1.15)):
				attack_cooldown = 1.15
				if _visual:
					_set_presentation_state("attack")
				var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
				if net and net.mode == "host" and pa:pa.damage(multiplayer.get_unique_id(), attack_damage)
				else:
					var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
					if state:state.damage_player(attack_damage)
	else:
		if enemy_authority:enemy_authority.set_state(self,"return")
		var home_dist := global_position.distance_to(spawn_position)
		if home_dist > 14.0:
			velocity = global_position.direction_to(spawn_position) * move_speed * 0.55
			move_and_slide()
			if _visual and _state != "hit":
				_apply_direction(_vector_to_direction(velocity))
				_set_presentation_state("idle")
		else:
			velocity = Vector2.ZERO
			if _visual and _state != "hit" and _state != "attack":
				_set_presentation_state("idle")

func _vector_to_direction(v: Vector2) -> String:
	if v.length_squared() <= 0.02:
		return _direction
	var angle := v.angle()
	var quad := int(round(angle / (TAU / 4.0))) % 4
	var mapping := ["right", "front", "left", "back"]
	return mapping[quad]

func take_damage(amount: int) -> void:
	hp -= amount
	hit_flash = 0.10
	if _visual:
		_set_presentation_state("hit")
	var fill := get_node_or_null("HpFill") as ColorRect
	if fill:
		fill.size.x = 68.0 * clamp(float(hp) / float(max_hp), 0.0, 1.0)
	if hp <= 0:
		_die()

func _exit_tree() -> void:
	var enemy_authority:=get_tree().get_first_node_in_group("enemy_authority_service") as BrambleEnemyAuthorityService
	if enemy_authority:enemy_authority.unregister_enemy(self)

func _die() -> void:
	if _visual:
		_set_presentation_state("defeated")
		await get_tree().create_timer(0.45).timeout
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state:
		state.register_enemy_kill(enemy_id, xp_reward, gold_reward)

	var loot := BrambleLootPickup.new()
	loot.gold_amount = gold_reward
	loot.global_position = global_position
	get_parent().add_child(loot)
	queue_free()
