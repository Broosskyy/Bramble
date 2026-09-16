class_name BrambleRuntimeMinimap
extends Control

@export var render_size := Vector2i(96, 72)

var _texture_rect: TextureRect
var _image_tex: ImageTexture
var _refresh_timer := 0.0

func _ready() -> void:
	_texture_rect = TextureRect.new()
	_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_texture_rect)
	_image_tex = ImageTexture.new()
	_texture_rect.texture = _image_tex

func _process(delta: float) -> void:
	_refresh_timer -= delta
	if _refresh_timer > 0.0:
		return
	_refresh_timer = 0.12
	_refresh()

func _refresh() -> void:
	var registry = get_tree().get_first_node_in_group("world_map_registry")
	if registry == null:
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		registry.set_player_position(player.global_position)
	var img: Image = registry.render_image(render_size)
	_image_tex.set_image(img)
