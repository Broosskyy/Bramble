class_name SpatialEntityPresenter
extends Node3D

## Camera-adaptive visual shell. Authoritative callers provide only world-facing,
## state and normalized time; camera yaw is a separate local presentation input.
enum DirectionMode {
	ONE_DIRECTION,
	TWO_DIRECTION,
	FOUR_DIRECTION,
	EIGHT_DIRECTION,
	CAMERA_BILLBOARD,
	CUSTOM,
}

const DIRECTIONS_8 := [
	"front", "front_right", "right", "back_right",
	"back", "back_left", "left", "front_left",
]

var profile: Dictionary = {}
var world_facing := Vector3(0.0, 0.0, 1.0)
var visual_state := "idle"
var normalized_time := 0.0
var camera_yaw := 0.0
var moving := false
var body_replacement_id := ""
var companion_slot_id := ""
var equipment_state_id := "none"
var equipment_visibility: Dictionary = {}

var body_sprite: Sprite3D
var equipment_sprites: Dictionary = {}
var _resolved_state := ""
var _resolved_direction := ""
var _resolved_texture_path := ""
var _base_height := 1.1


func configure(new_profile: Dictionary) -> void:
	profile = new_profile.duplicate(true)
	name = str(profile.get("id", "SpatialEntityPresenter"))
	_base_height = float(profile.get("base_height", 1.1))
	_build_layers()
	apply_presentation()


func consume_world_snapshot(snapshot: Dictionary) -> void:
	# Intentionally accepts no camera property. This keeps replay/network/SP and
	# companion payloads camera-independent and body-replacement compatible.
	world_facing = _vector3(snapshot.get("world_facing", world_facing)).normalized()
	if world_facing.length_squared() < 0.01:
		world_facing = Vector3(0.0, 0.0, 1.0)
	visual_state = str(snapshot.get("state", visual_state))
	normalized_time = clampf(float(snapshot.get("normalized_time", normalized_time)), 0.0, 1.0)
	moving = bool(snapshot.get("moving", moving))
	body_replacement_id = str(snapshot.get("body_replacement_id", body_replacement_id))
	companion_slot_id = str(snapshot.get("companion_slot_id", companion_slot_id))
	equipment_state_id = str(snapshot.get("equipment_state_id", equipment_state_id))
	if snapshot.has("equipment_visibility"):
		equipment_visibility = snapshot.equipment_visibility.duplicate()
	apply_presentation()


func set_local_camera_yaw(local_yaw: float) -> void:
	camera_yaw = local_yaw
	apply_presentation()


func apply_presentation() -> void:
	if profile.is_empty() or body_sprite == null:
		return
	var state_name := _resolve_state(visual_state)
	var state_data: Dictionary = profile.get("states", {}).get(state_name, {})
	var direction := _resolve_direction(state_data)
	var texture_path := _resolve_texture(state_data, direction)
	if texture_path != "" and texture_path != _resolved_texture_path:
		body_sprite.texture = load(texture_path)
		_resolved_texture_path = texture_path
	_resolved_state = state_name
	_resolved_direction = direction
	_apply_motion(state_data, direction)
	_apply_equipment(direction, state_name)


func get_resolved_direction() -> String:
	return _resolved_direction


func get_resolved_state() -> String:
	return _resolved_state


func get_visual_counts() -> Dictionary:
	return {
		"sprites": 1 + equipment_sprites.size(),
		"animated_entities": 1,
		"transparent": 1 + equipment_sprites.size(),
	}


func set_equipment_state(state_id: String, visibility: Dictionary) -> void:
	equipment_state_id = state_id
	equipment_visibility = visibility.duplicate()
	apply_presentation()


func get_visible_equipment_count() -> int:
	var count := 0
	for sprite in equipment_sprites.values():
		if (sprite as Sprite3D).visible:
			count += 1
	return count


func resolver_probe(state: String, probe_facing: Vector3, probe_yaw: float) -> Dictionary:
	var previous_state := visual_state
	var previous_facing := world_facing
	var previous_yaw := camera_yaw
	visual_state = state
	world_facing = probe_facing
	camera_yaw = probe_yaw
	apply_presentation()
	var result := {"state": _resolved_state, "direction": _resolved_direction, "flip_h": body_sprite.flip_h}
	visual_state = previous_state
	world_facing = previous_facing
	camera_yaw = previous_yaw
	apply_presentation()
	return result


func _build_layers() -> void:
	for child in get_children():
		child.queue_free()
	equipment_sprites.clear()
	body_sprite = _new_sprite(float(profile.get("pixel_size", 0.0055)))
	body_sprite.name = "BodyVisual"
	body_sprite.position.y = _base_height
	add_child(body_sprite)
	var layers: Dictionary = profile.get("equipment_layers", {})
	for layer_name in layers:
		var layer_data: Dictionary = layers[layer_name]
		var sprite := _new_sprite(float(layer_data.get("pixel_size", profile.get("pixel_size", 0.0055))))
		sprite.name = "%sVisual" % str(layer_name).capitalize()
		sprite.position.y = _base_height
		sprite.render_priority = int(layer_data.get("render_priority", 1))
		add_child(sprite)
		equipment_sprites[layer_name] = sprite


func _new_sprite(pixel_size: float) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.pixel_size = pixel_size
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return sprite


func _resolve_direction(state_data: Dictionary = {}) -> String:
	var relative := wrapf(atan2(world_facing.x, world_facing.z) - camera_yaw, -PI, PI)
	var index := posmod(int(round(relative / (TAU / 8.0))), 8)
	var eight: String = DIRECTIONS_8[index]
	var mode := int(state_data.get("direction_mode", profile.get("direction_mode", DirectionMode.ONE_DIRECTION)))
	match mode:
		DirectionMode.ONE_DIRECTION, DirectionMode.CAMERA_BILLBOARD:
			return "front"
		DirectionMode.TWO_DIRECTION:
			return "right" if index in [1, 2, 3] else "left" if index in [5, 6, 7] else "front"
		DirectionMode.FOUR_DIRECTION:
			return {"front_right": "front", "front_left": "front", "back_right": "back", "back_left": "back"}.get(eight, eight)
		DirectionMode.EIGHT_DIRECTION:
			return eight
		DirectionMode.CUSTOM:
			var custom: Array = state_data.get("custom_directions", profile.get("custom_directions", ["front"]))
			if custom.is_empty():
				return "front"
			return str(custom[posmod(int(round(relative / (TAU / float(custom.size())))), custom.size())])
	return "front"


func _resolve_state(requested: String) -> String:
	var states: Dictionary = profile.get("states", {})
	if states.has(requested):
		return requested
	var fallback := str(profile.get("fallback_state", "idle"))
	assert(states.has(fallback), "Spatial profile requires a valid fallback_state")
	return fallback


func _resolve_texture(state_data: Dictionary, direction: String) -> String:
	var equipment_sequences: Dictionary = state_data.get("equipment_cel_sequences", {})
	var equipment_sequence: Array = equipment_sequences.get(equipment_state_id, [])
	if not equipment_sequence.is_empty():
		var equipment_frame := mini(int(floor(normalized_time * equipment_sequence.size())), equipment_sequence.size() - 1)
		body_sprite.flip_h = false
		return str(equipment_sequence[equipment_frame])
	var directional: Dictionary = state_data.get("directional_frames", {})
	if directional.has(direction):
		body_sprite.flip_h = false
		return str(directional[direction])
	var sequence: Array = state_data.get("cel_sequence", [])
	if not sequence.is_empty():
		var frame := mini(int(floor(normalized_time * sequence.size())), sequence.size() - 1)
		body_sprite.flip_h = false
		return str(sequence[frame])
	var nearest: Dictionary = state_data.get("nearest_fallback", profile.get("nearest_fallback", {}))
	if nearest.has(direction) and directional.has(str(nearest[direction])):
		body_sprite.flip_h = false
		return str(directional[str(nearest[direction])])
	var mirror: Dictionary = state_data.get("mirror_explicit", profile.get("mirror_explicit", {}))
	if mirror.has(direction):
		var source := str(mirror[direction])
		assert(directional.has(source), "Explicit mirror source is missing")
		body_sprite.flip_h = true
		return str(directional[source])
	body_sprite.flip_h = false
	var generic := str(state_data.get("authored_generic", ""))
	if generic == "":
		var fallback_state := str(state_data.get("fallback_state", profile.get("fallback_state", "idle")))
		var fallback_data: Dictionary = profile.get("states", {}).get(fallback_state, {})
		if fallback_data != state_data:
			return _resolve_texture(fallback_data, direction)
	assert(generic != "", "No authored frame and no explicit fallback for %s" % direction)
	return generic


func _apply_motion(state_data: Dictionary, direction: String) -> void:
	var motion: Dictionary = state_data.get("motion_profile", {})
	var phase := normalized_time * TAU
	var bob := sin(phase) * float(motion.get("bob", 0.0))
	var squash := sin(phase) * float(motion.get("squash", 0.0))
	var anticipation := sin(clampf(normalized_time / 0.28, 0.0, 1.0) * PI) * float(motion.get("anticipation", 0.0))
	var recoil := sin(clampf((normalized_time - 0.55) / 0.3, 0.0, 1.0) * PI) * float(motion.get("recoil", 0.0))
	position = Vector3(anticipation - recoil, bob, 0.0)
	scale = Vector3(1.0 + squash, 1.0 - squash - anticipation * 0.22, 1.0)
	rotation_degrees.z = float(motion.get("defeat_tilt", 0.0)) * normalized_time
	body_sprite.position = Vector3(0.0, _base_height, 0.0)
	if motion.has("attack_lunge"):
		var sign_by_direction: Dictionary = motion.get("screen_sign_by_direction", {})
		var direction_sign := float(sign_by_direction.get(direction, 1.0))
		var windup := float(motion.get("attack_windup", 0.08))
		var lunge := float(motion.get("attack_lunge", 0.24))
		var lean := float(motion.get("attack_lean_degrees", 10.0))
		var travel := 0.0
		var body_lean := 0.0
		if normalized_time < 0.20:
			var t := smoothstep(0.0, 0.20, normalized_time)
			travel = lerpf(0.0, -windup, t)
			body_lean = lerpf(0.0, -lean * 0.55, t)
		elif normalized_time < 0.42:
			var t := smoothstep(0.20, 0.42, normalized_time)
			travel = lerpf(-windup, lunge, t)
			body_lean = lerpf(-lean * 0.55, lean, t)
		elif normalized_time < 0.70:
			var t := smoothstep(0.42, 0.70, normalized_time)
			travel = lerpf(lunge, lunge * 0.42, t)
			body_lean = lerpf(lean, lean * 0.38, t)
		else:
			var t := smoothstep(0.70, 1.0, normalized_time)
			travel = lerpf(lunge * 0.42, 0.0, t)
			body_lean = lerpf(lean * 0.38, 0.0, t)
		position.x = travel * direction_sign
		rotation_degrees.z = body_lean * direction_sign
		var compression := sin(clampf(normalized_time / 0.20, 0.0, 1.0) * PI) * float(motion.get("attack_compression", 0.025))
		scale = Vector3(1.0 + compression, 1.0 - compression, 1.0)


func _apply_equipment(direction: String, state_name: String) -> void:
	var layers: Dictionary = profile.get("equipment_layers", {})
	for layer_name in equipment_sprites:
		var sprite: Sprite3D = equipment_sprites[layer_name]
		var data: Dictionary = layers[layer_name]
		sprite.visible = bool(equipment_visibility.get(layer_name, data.get("visible", true)))
		var textures: Dictionary = data.get("directional_frames", {})
		if textures.has(direction):
			sprite.hframes = 1
			sprite.vframes = 1
			sprite.frame = 0
			sprite.texture = load(str(textures[direction]))
		elif data.has("atlas"):
			sprite.texture = load(str(data.atlas))
			sprite.hframes = int(data.get("hframes", 1))
			sprite.vframes = int(data.get("vframes", 1))
			sprite.frame = DIRECTIONS_8.find(direction)
		else:
			sprite.texture = null
			sprite.hframes = 1
			sprite.vframes = 1
			sprite.frame = 0
		var anchors: Dictionary = data.get("anchors", {})
		var anchor: Array = anchors.get(direction, [0.0, 0.0])
		sprite.position = Vector3(float(anchor[0]), _base_height + float(anchor[1]), float(data.get("z_offset", 0.0)))
		if state_name == "attack":
			var offset_times: Array = data.get("attack_offset_times", [])
			var offset_x: Array = data.get("attack_offset_x", [])
			var offset_y: Array = data.get("attack_offset_y", [])
			if offset_times.size() == offset_x.size() and offset_times.size() == offset_y.size() and offset_times.size() >= 2:
				var signs: Dictionary = data.get("attack_offset_sign_by_direction", {})
				var offset_sign := float(signs.get(direction, 1.0))
				sprite.position.x += _sample_float_curve(offset_times, offset_x, normalized_time) * offset_sign
				sprite.position.y += _sample_float_curve(offset_times, offset_y, normalized_time)
		var depths: Dictionary = data.get("depth_by_direction", {})
		sprite.render_priority = int(depths.get(direction, data.get("render_priority", 1)))
		var state_scale: Dictionary = data.get("state_scale", {})
		sprite.scale = Vector3.ONE * float(state_scale.get(state_name, 1.0))
		var base_rotations: Dictionary = data.get("rotation_by_direction", {})
		var rotation := float(base_rotations.get(direction, 0.0))
		if state_name == "attack" and (data.has("attack_swing_keyframes") or data.has("attack_swing_degrees")):
			var swing_times: Array = data.get("attack_swing_times", [])
			var swing_angles: Array = data.get("attack_swing_keyframes", [])
			if swing_times.size() == swing_angles.size() and swing_times.size() >= 2:
				rotation += _sample_float_curve(swing_times, swing_angles, normalized_time)
			else:
				var swing: Array = data.get("attack_swing_degrees", [-50.0, 45.0])
				rotation += lerpf(float(swing[0]), float(swing[1]), smoothstep(0.18, 0.72, normalized_time))
		sprite.rotation_degrees.z = rotation


func _sample_float_curve(times: Array, values: Array, sample: float) -> float:
	for index in range(1, times.size()):
		if sample <= float(times[index]):
			var from_time := float(times[index - 1])
			var to_time := float(times[index])
			var weight := inverse_lerp(from_time, to_time, sample)
			return lerpf(float(values[index - 1]), float(values[index]), smoothstep(0.0, 1.0, weight))
	return float(values[-1])


func _vector3(value: Variant) -> Vector3:
	if value is Vector3:
		return value
	if value is Array and value.size() >= 3:
		return Vector3(float(value[0]), float(value[1]), float(value[2]))
	return Vector3(0.0, 0.0, 1.0)
