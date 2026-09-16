class_name BrambleProductionHud
extends CanvasLayer

const HUD_STATS_SIZE := Vector2(240, 86)
const HUD_QUEST_SIZE := Vector2(300, 70)
const HUD_MINIMAP_SIZE := Vector2(132, 104)
const HUD_JOY_SIZE := Vector2(136, 136)
const HUD_ATTACK_SIZE := Vector2(76, 76)
const HUD_SKILL_SIZE := Vector2(44, 44)

var stats_root: Control
var stats_panel: TextureRect
var hp_bar: ProgressBar
var mp_bar: ProgressBar
var stats_label: Label
var quest_root: Control
var quest_title: Label
var quest_text: Label
var minimap_root: Control
var minimap_view: Control
var touch_root: Control
var combat_root: Control
var dialogue: PanelContainer
var dialogue_title: Label
var dialogue_text: Label
var toast: Label
var attack_btn: TextureButton
var skill_btns: Array[TextureButton] = []

var toast_time := 0.0

func _ready() -> void:
	add_to_group("production_hud")
	_build_ui()
	_bind_touch()
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state:
		state.quest_changed.connect(_on_quest_changed)
		state.player_stats_changed.connect(_on_stats_changed)
		state.toast_requested.connect(show_toast)
		state._emit_all()
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient.orientation_changed.connect(_apply_layout)
		_apply_layout(orient.mode_name())

func _build_ui() -> void:
	stats_root = _fixed_panel(HUD_STATS_SIZE)
	add_child(stats_root)
	stats_panel = _scaled_tex("ui/hud/player_status_panel.png", HUD_STATS_SIZE)
	stats_root.add_child(stats_panel)
	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(72, 34)
	hp_bar.size = Vector2(150, 12)
	hp_bar.show_percentage = false
	stats_root.add_child(hp_bar)
	mp_bar = ProgressBar.new()
	mp_bar.position = Vector2(72, 50)
	mp_bar.size = Vector2(150, 10)
	mp_bar.show_percentage = false
	mp_bar.modulate = Color(0.55, 0.75, 1.0)
	stats_root.add_child(mp_bar)
	stats_label = Label.new()
	stats_label.position = Vector2(72, 12)
	stats_label.add_theme_font_size_override("font_size", 11)
	stats_root.add_child(stats_label)

	quest_root = _fixed_panel(HUD_QUEST_SIZE)
	add_child(quest_root)
	var quest_bg := _scaled_tex("ui/quests/quest_tracker_panel.png", HUD_QUEST_SIZE)
	quest_root.add_child(quest_bg)
	quest_title = Label.new()
	quest_title.position = Vector2(14, 8)
	quest_title.add_theme_font_size_override("font_size", 12)
	quest_title.add_theme_color_override("font_color", Color("#ffe6a0"))
	quest_root.add_child(quest_title)
	quest_text = Label.new()
	quest_text.position = Vector2(14, 28)
	quest_text.size = Vector2(272, 34)
	quest_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_text.add_theme_font_size_override("font_size", 10)
	quest_root.add_child(quest_text)

	minimap_root = _fixed_panel(HUD_MINIMAP_SIZE)
	add_child(minimap_root)
	var mini_bg := _scaled_tex("ui/map/kit62_minimap_bezel.png", HUD_MINIMAP_SIZE)
	minimap_root.add_child(mini_bg)
	minimap_view = load("res://scripts/runtime_minimap.gd").new()
	minimap_view.render_size = Vector2i(96, 72)
	minimap_view.position = Vector2(18, 18)
	minimap_view.size = HUD_MINIMAP_SIZE - Vector2(36, 36)
	minimap_root.add_child(minimap_view)

	touch_root = _fixed_panel(HUD_JOY_SIZE)
	add_child(touch_root)
	var joy := _scaled_tex("ui/hud/kit62_virtual_joystick.png", HUD_JOY_SIZE)
	joy.name = "JoystickBase"
	touch_root.add_child(joy)
	for spec in [["Up", Vector2(46, 0)], ["Down", Vector2(46, 92)], ["Left", Vector2(0, 46)], ["Right", Vector2(92, 46)]]:
		var b := Button.new()
		b.name = spec[0]
		b.position = spec[1]
		b.size = Vector2(44, 44)
		b.modulate = Color(1, 1, 1, 0.22)
		touch_root.add_child(b)

	combat_root = Control.new()
	add_child(combat_root)
	attack_btn = TextureButton.new()
	attack_btn.ignore_texture_size = true
	attack_btn.stretch_mode = TextureButton.STRETCH_SCALE
	attack_btn.texture_normal = BrambleWorldPresentationConfig.game_tex("ui/hud/primary_attack_button.png")
	attack_btn.custom_minimum_size = HUD_ATTACK_SIZE
	attack_btn.size = HUD_ATTACK_SIZE
	combat_root.add_child(attack_btn)
	for i in range(1, 4):
		var slot := TextureButton.new()
		slot.name = "Skill%d" % i
		slot.ignore_texture_size = true
		slot.custom_minimum_size = HUD_SKILL_SIZE
		slot.size = HUD_SKILL_SIZE
		slot.modulate = Color(0.92, 0.86, 0.72, 0.95)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.10, 0.08, 0.82)
		style.border_color = Color("#c8a56a")
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		slot.add_theme_stylebox_override("normal", style)
		slot.add_theme_stylebox_override("hover", style)
		slot.add_theme_stylebox_override("pressed", style)
		var num := Label.new()
		num.text = str(i)
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		num.set_anchors_preset(Control.PRESET_FULL_RECT)
		num.add_theme_font_size_override("font_size", 14)
		slot.add_child(num)
		combat_root.add_child(slot)
		skill_btns.append(slot)

	dialogue = PanelContainer.new()
	dialogue.visible = false
	add_child(dialogue)
	var dm := MarginContainer.new()
	dialogue.add_child(dm)
	var dv := VBoxContainer.new()
	dm.add_child(dv)
	dialogue_title = Label.new()
	dv.add_child(dialogue_title)
	dialogue_text = Label.new()
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.custom_minimum_size = Vector2(420, 80)
	dv.add_child(dialogue_text)
	var close := Button.new()
	close.text = "OK"
	close.pressed.connect(func(): dialogue.visible = false)
	dv.add_child(close)
	toast = Label.new()
	toast.visible = false
	add_child(toast)

func _fixed_panel(panel_size: Vector2) -> Control:
	var root := Control.new()
	root.custom_minimum_size = panel_size
	root.size = panel_size
	return root

func _scaled_tex(relative_path: String, panel_size: Vector2) -> TextureRect:
	var tex := TextureRect.new()
	tex.texture = BrambleWorldPresentationConfig.game_tex(relative_path)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.custom_minimum_size = panel_size
	tex.size = panel_size
	return tex

func _bind_touch() -> void:
	_bind_btn(touch_root.get_node("Up"), "move_up")
	_bind_btn(touch_root.get_node("Down"), "move_down")
	_bind_btn(touch_root.get_node("Left"), "move_left")
	_bind_btn(touch_root.get_node("Right"), "move_right")
	attack_btn.button_down.connect(func(): Input.action_press("basic_attack"))
	attack_btn.button_up.connect(func(): Input.action_release("basic_attack"))
	for i in range(skill_btns.size()):
		var slot := skill_btns[i]
		var action := "skill_%d" % (i + 1)
		slot.button_down.connect(func(): Input.action_press(action))
		slot.button_up.connect(func(): Input.action_release(action))

func _bind_btn(button: BaseButton, action: String) -> void:
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))

func _apply_layout(mode: String) -> void:
	var portrait := mode == "portrait"
	var vp := get_viewport().get_visible_rect().size
	var m := BrambleWorldPresentationConfig.HUD_SAFE_MARGIN
	var joy_h := BrambleWorldPresentationConfig.HUD_JOYSTICK_ZONE_HEIGHT
	var stats_h := HUD_STATS_SIZE.y
	var quest_h := HUD_QUEST_SIZE.y

	if portrait:
		stats_root.position = Vector2(m, 48)
		quest_root.position = Vector2(m, 48 + stats_h + 10)
		quest_root.size = Vector2(280, 64)
		minimap_root.position = Vector2(vp.x - HUD_MINIMAP_SIZE.x - m, 44)
		touch_root.position = Vector2(m, vp.y - HUD_JOY_SIZE.y - m)
		combat_root.position = Vector2(vp.x - 112, vp.y - joy_h + 6)
	else:
		stats_root.position = Vector2(m, m)
		quest_root.position = Vector2(m, m + stats_h + 8)
		quest_root.size = HUD_QUEST_SIZE
		minimap_root.position = Vector2(vp.x - HUD_MINIMAP_SIZE.x - m, m)
		var joy_y := vp.y - HUD_JOY_SIZE.y - m
		if joy_y < quest_root.position.y + quest_h + 12:
			joy_y = quest_root.position.y + quest_h + 12
		touch_root.position = Vector2(m, joy_y)
		combat_root.position = Vector2(vp.x - 118, vp.y - HUD_ATTACK_SIZE.y - m)

	attack_btn.position = Vector2(0, 0)
	for i in range(skill_btns.size()):
		skill_btns[i].position = Vector2(-50 * (i + 1), 18)

func _process(delta: float) -> void:
	if toast_time > 0.0:
		toast_time -= delta
		if toast_time <= 0.0:
			toast.visible = false

func _on_quest_changed(title: String, text: String) -> void:
	quest_title.text = title
	quest_text.text = text

func _on_stats_changed(hp: int, max_hp: int, level: int, xp: int, gold: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	mp_bar.max_value = 100
	mp_bar.value = clampi(100 - level * 3, 35, 100)
	stats_label.text = "LV %d  XP %d  %d G" % [level, xp, gold]

func show_dialogue(title: String, text: String) -> void:
	dialogue_title.text = title
	dialogue_text.text = text
	dialogue.position = Vector2(40, get_viewport().get_visible_rect().size.y * 0.52)
	dialogue.visible = true

func show_toast(text: String) -> void:
	toast.text = text
	toast.position = Vector2(BrambleWorldPresentationConfig.HUD_SAFE_MARGIN, 96)
	toast.visible = true
	toast_time = 2.4
