class_name BramblePlayerVisual
extends AnimatedSprite2D

signal pose_changed(pose: String, facing_left: bool)
signal facing_changed(direction: String)

@export_enum("male","female") var gender := "male"
@export var use_production_assets := false

var registry := BrambleAssetRegistry.new()
var _last_pose := ""
var _last_flip := false
var _direction := "front"
var _dir_textures: Dictionary = {}
var _walk_frames: Array[Texture2D] = []
var _hit_texture: Texture2D
var _defeated_texture: Texture2D
var _base_y := -58.0
var _hit_time := 0.0

const DIR_NAMES := [
	"front", "front_right", "right", "back_right",
	"back", "back_left", "left", "front_left"
]
const FRONTISH := ["front", "front_left", "front_right"]

func _ready() -> void:
	if use_production_assets:
		_setup_production_visual()
		return
	if not registry.load_registry():
		push_error("BRAMBLE: player animation registry could not load.")
		return
	sprite_frames = SpriteFrames.new()
	_add("idle", ["idle_open","idle_blink"], 2.0, true)
	_add("run", ["walk_step_a","walk_step_b"], 8.0, true)
	_add("attack", ["attack_prepare_empty","attack_release_empty","attack_recover_empty"], 11.0, false)
	_add("hit", ["hit_recoil"], 4.0, false)
	play("idle")

func _setup_production_visual() -> void:
	scale = Vector2.ONE * BrambleWorldPresentationConfig.PLAYER_VISUAL_SCALE
	position = Vector2(0, -58)
	_base_y = position.y
	for dir_name in DIR_NAMES:
		var path := "characters/base/%s/directions/%s.png" % [gender, dir_name]
		_dir_textures[dir_name] = BrambleWorldPresentationConfig.game_tex(path)
	for walk_name in ["walk_a", "walk_b"]:
		var tex := BrambleWorldPresentationConfig.game_tex("characters/base/%s/animations/walk/%s.png" % [gender, walk_name])
		if tex:
			_walk_frames.append(tex)
	_hit_texture = BrambleWorldPresentationConfig.game_tex("characters/base/%s/animations/hit.png" % gender)
	_defeated_texture = BrambleWorldPresentationConfig.game_tex("characters/base/%s/animations/defeated.png" % gender)
	sprite_frames = SpriteFrames.new()
	for anim in ["idle", "run", "hit", "defeated"]:
		sprite_frames.add_animation(anim)
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_loop("run", true)
	sprite_frames.set_animation_loop("hit", false)
	sprite_frames.set_animation_loop("defeated", false)
	if _walk_frames.size() >= 2:
		sprite_frames.set_animation_speed("run", 7.5)
	_apply_direction_texture("front")
	play("idle")

func _process(delta: float) -> void:
	if use_production_assets:
		if _hit_time > 0.0:
			_hit_time = maxf(0.0, _hit_time - delta)
			if _hit_time <= 0.0 and animation == "hit":
				play("idle")
		position.y = _base_y
		return
	var pose := semantic_pose()
	if pose != _last_pose or flip_h != _last_flip:
		_last_pose = pose
		_last_flip = flip_h
		pose_changed.emit(pose, flip_h)

func _add(name: String, poses: Array[String], fps: float, looped: bool) -> void:
	if not sprite_frames.has_animation(name):
		sprite_frames.add_animation(name)
	sprite_frames.set_animation_speed(name, fps)
	sprite_frames.set_animation_loop(name, looped)
	for t in registry.character_frames(gender, poses):
		if t != null:
			sprite_frames.add_frame(name, t)

func semantic_pose() -> String:
	if animation == "idle":
		return "idle_blink" if frame == 1 else "idle_open"
	if animation == "run":
		return "walk_step_b" if frame == 1 else "walk_step_a"
	if animation == "attack":
		return ["attack_prepare_empty","attack_release_empty","attack_recover_empty"][mini(frame, 2)]
	if animation == "hit":
		return "hit_recoil"
	return "idle_open"

func set_state(state: String) -> void:
	if not sprite_frames.has_animation(state):
		return
	if animation != state:
		play(state)

func show_hit() -> void:
	if not use_production_assets or _hit_texture == null:
		set_state("hit")
		return
	_populate_single_frame("hit", _hit_texture)
	set_state("hit")
	_hit_time = 0.35

func show_defeated() -> void:
	if not use_production_assets or _defeated_texture == null:
		return
	_populate_single_frame("defeated", _defeated_texture)
	set_state("defeated")

func set_facing_from_velocity(input_vec: Vector2) -> void:
	if not use_production_assets:
		if absf(input_vec.x) > 0.05:
			flip_h = input_vec.x < 0.0
		return
	if _hit_time > 0.0:
		return
	var dir := _vector_to_direction(input_vec)
	var moving := input_vec.length_squared() > 0.02
	if moving:
		if _walk_frames.size() >= 2 and dir in FRONTISH:
			_apply_walk_cycle()
			set_state("run")
		else:
			_apply_direction_texture(dir)
			set_state("idle")
	else:
		_apply_direction_texture(dir)
		set_state("idle")
	if dir != _direction:
		_direction = dir
		facing_changed.emit(dir)

func _vector_to_direction(v: Vector2) -> String:
	if v.length_squared() <= 0.02:
		return _direction
	var angle := v.angle()
	var oct := int(round(angle / (TAU / 8.0))) % 8
	var mapping := ["right", "front_right", "front", "front_left", "left", "back_left", "back", "back_right"]
	return mapping[oct]

func _apply_direction_texture(dir: String) -> void:
	var tex: Texture2D = _dir_textures.get(dir, _dir_textures.get("front"))
	if tex == null:
		return
	_populate_single_frame("idle", tex)
	flip_h = false

func _apply_walk_cycle() -> void:
	sprite_frames.clear("run")
	for tex in _walk_frames:
		sprite_frames.add_frame("run", tex)
	flip_h = false

func _populate_single_frame(anim: String, tex: Texture2D) -> void:
	if not sprite_frames.has_animation(anim):
		sprite_frames.add_animation(anim)
	sprite_frames.clear(anim)
	sprite_frames.add_frame(anim, tex)
