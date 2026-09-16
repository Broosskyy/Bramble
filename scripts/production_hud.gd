class_name BrambleProductionHud
extends CanvasLayer

const HUD_STATS_SIZE := Vector2(260, 92)
const HUD_QUEST_SIZE := Vector2(300, 70)
const HUD_MINIMAP_SIZE := Vector2(132, 104)
const HUD_JOY_SIZE := Vector2(136, 136)
const HUD_ATTACK_SIZE := Vector2(84, 84)
const HUD_SKILL_SIZE := Vector2(58, 58)

var stats_root: Control
var stats_panel: TextureRect
var portrait_icon: TextureRect
var level_badge: Label
var hp_bar: ProgressBar
var mp_bar: ProgressBar
var xp_bar: ProgressBar
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
var skill_cd_labels: Array[Label] = []
var skill_icons: Array[TextureRect] = []
var target_root: Control
var target_name: Label
var target_hp: ProgressBar
var target_status: Label
var nav_root: Control
var level_up_root: Control
var level_up_title: Label
var level_up_level: Label
var level_up_rewards: Label

var toast_time := 0.0
var level_up_time := 0.0

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
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	if targeting:
		targeting.target_changed.connect(_on_target_changed)
	var runtime = get_tree().get_first_node_in_group("combat_runtime_service")
	if runtime:
		runtime.skill_cooldown_changed.connect(_on_skill_cooldown)
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs:
		cs.character_changed.connect(_on_character_changed)
		cs.level_up.connect(_on_level_up)
		_on_character_changed(cs.get_character_view())
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient.orientation_changed.connect(_apply_layout)
		_apply_layout(orient.mode_name())

func _build_ui() -> void:
	stats_root = _fixed_panel(HUD_STATS_SIZE)
	add_child(stats_root)
	stats_panel = _scaled_tex("ui/hud/player_status_panel.png", HUD_STATS_SIZE)
	stats_root.add_child(stats_panel)
	portrait_icon = TextureRect.new()
	portrait_icon.texture = BrambleWorldPresentationConfig.game_tex("characters/base/male/directions/front.png")
	portrait_icon.position = Vector2(8, 8)
	portrait_icon.custom_minimum_size = Vector2(52, 52)
	portrait_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stats_root.add_child(portrait_icon)
	level_badge = Label.new()
	level_badge.position = Vector2(8, 58)
	level_badge.custom_minimum_size = Vector2(52, 16)
	level_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_badge.add_theme_font_size_override("font_size", 12)
	level_badge.add_theme_color_override("font_color", Color("#ffe6a0"))
	stats_root.add_child(level_badge)
	hp_bar = _styled_bar(Vector2(72, 28), Vector2(178, 14), Color("#c44"))
	stats_root.add_child(hp_bar)
	mp_bar = _styled_bar(Vector2(72, 46), Vector2(178, 12), Color("#58a"))
	stats_root.add_child(mp_bar)
	xp_bar = _styled_bar(Vector2(72, 62), Vector2(178, 10), Color("#7a5"))
	stats_root.add_child(xp_bar)
	stats_label = Label.new()
	stats_label.position = Vector2(72, 8)
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_color_override("font_color", Color("#f0e8d8"))
	stats_root.add_child(stats_label)

	quest_root = _fixed_panel(HUD_QUEST_SIZE)
	add_child(quest_root)
	var quest_bg := _scaled_tex("ui/quests/quest_tracker_panel.png", HUD_QUEST_SIZE)
	quest_root.add_child(quest_bg)
	quest_title = Label.new()
	quest_title.position = Vector2(14, 8)
	quest_title.add_theme_font_size_override("font_size", 13)
	quest_title.add_theme_color_override("font_color", Color("#ffe6a0"))
	quest_root.add_child(quest_title)
	quest_text = Label.new()
	quest_text.position = Vector2(14, 28)
	quest_text.size = Vector2(272, 34)
	quest_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_text.add_theme_font_size_override("font_size", 11)
	quest_root.add_child(quest_text)

	target_root = _fixed_panel(Vector2(240, 56))
	target_root.visible = false
	add_child(target_root)
	var target_bg := _scaled_tex("ui/target/target_status_panel.png", Vector2(240, 56))
	if target_bg.texture == null:
		target_bg.texture = BrambleWorldPresentationConfig.game_tex("ui/quests/quest_tracker_panel.png")
	target_root.add_child(target_bg)
	target_name = Label.new()
	target_name.position = Vector2(12, 6)
	target_name.add_theme_font_size_override("font_size", 13)
	target_root.add_child(target_name)
	target_hp = ProgressBar.new()
	target_hp.position = Vector2(12, 26)
	target_hp.size = Vector2(216, 12)
	target_hp.show_percentage = false
	target_root.add_child(target_hp)
	target_status = Label.new()
	target_status.position = Vector2(12, 40)
	target_status.add_theme_font_size_override("font_size", 10)
	target_root.add_child(target_status)

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
	for i in range(3):
		var slot := TextureButton.new()
		slot.name = "Skill%d" % (i + 1)
		slot.ignore_texture_size = true
		slot.custom_minimum_size = HUD_SKILL_SIZE
		slot.size = HUD_SKILL_SIZE
		slot.texture_normal = BrambleWorldPresentationConfig.game_tex("ui/skills/skill_button.png")
		slot.texture_disabled = BrambleWorldPresentationConfig.game_tex("ui/skills/skill_locked.png")
		slot.texture_pressed = BrambleWorldPresentationConfig.game_tex("ui/skills/skill_cooldown.png")
		combat_root.add_child(slot)
		skill_btns.append(slot)
		var icon := TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.custom_minimum_size = Vector2(40, 40)
		icon.position = Vector2(9, 9)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.add_child(icon)
		skill_icons.append(icon)
		var cd := Label.new()
		cd.visible = false
		cd.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cd.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cd.set_anchors_preset(Control.PRESET_FULL_RECT)
		cd.add_theme_font_size_override("font_size", 14)
		cd.add_theme_color_override("font_color", Color("#ffd35a"))
		slot.add_child(cd)
		skill_cd_labels.append(cd)

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
	_build_nav()
	_build_level_up()

func _build_level_up() -> void:
	level_up_root = Control.new()
	level_up_root.visible = false
	level_up_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(level_up_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.25)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_up_root.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -160
	panel.offset_top = -72
	panel.offset_right = 160
	panel.offset_bottom = 72
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.04, 0.88)
	style.border_color = Color("#e8c86a")
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(1.0, 0.82, 0.35, 0.35)
	style.shadow_size = 12
	panel.add_theme_stylebox_override("panel", style)
	level_up_root.add_child(panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)
	level_up_title = Label.new()
	level_up_title.text = "LEVEL UP"
	level_up_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_up_title.add_theme_font_size_override("font_size", 22)
	level_up_title.add_theme_color_override("font_color", Color("#ffe6a0"))
	box.add_child(level_up_title)
	level_up_level = Label.new()
	level_up_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_up_level.add_theme_font_size_override("font_size", 28)
	level_up_level.add_theme_color_override("font_color", Color.WHITE)
	box.add_child(level_up_level)
	level_up_rewards = Label.new()
	level_up_rewards.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_up_rewards.add_theme_font_size_override("font_size", 13)
	level_up_rewards.add_theme_color_override("font_color", Color("#c8e8a0"))
	box.add_child(level_up_rewards)

func _build_nav() -> void:
	nav_root = Control.new()
	add_child(nav_root)
	for spec in [["Tasche", "inventory"], ["Held", "character"], ["Quest", "quest"], ["Sozial", "social"]]:
		var b := Button.new()
		b.text = spec[0]
		b.name = spec[1]
		b.custom_minimum_size = Vector2(72, 44)
		b.add_theme_font_size_override("font_size", 12)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.10, 0.08, 0.06, 0.88)
		style.border_color = Color("#c8a56a")
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		b.add_theme_stylebox_override("normal", style)
		b.add_theme_stylebox_override("hover", style)
		b.add_theme_stylebox_override("pressed", style)
		b.pressed.connect(func(): _on_nav(spec[1]))
		nav_root.add_child(b)

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

func _styled_bar(pos: Vector2, size: Vector2, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = size
	bar.show_percentage = false
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.07, 0.06, 0.85)
	bg.set_corner_radius_all(4)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	return bar

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
		target_root.position = Vector2(m, 48 + stats_h + quest_h + 18)
		minimap_root.position = Vector2(vp.x - HUD_MINIMAP_SIZE.x - m, 44)
		touch_root.position = Vector2(m, vp.y - HUD_JOY_SIZE.y - m)
		combat_root.position = Vector2(vp.x - 132, vp.y - joy_h + 4)
	else:
		stats_root.position = Vector2(m, m)
		quest_root.position = Vector2(m, m + stats_h + 8)
		quest_root.size = HUD_QUEST_SIZE
		target_root.position = Vector2(vp.x * 0.5 - 120, m)
		minimap_root.position = Vector2(vp.x - HUD_MINIMAP_SIZE.x - m, m)
		var joy_y := vp.y - HUD_JOY_SIZE.y - m
		if joy_y < quest_root.position.y + quest_h + 12:
			joy_y = quest_root.position.y + quest_h + 12
		touch_root.position = Vector2(m, joy_y)
		combat_root.position = Vector2(vp.x - 132, vp.y - HUD_ATTACK_SIZE.y - m)

	attack_btn.position = Vector2(0, 0)
	for i in range(skill_btns.size()):
		skill_btns[i].position = Vector2(-62 * (i + 1), 14)
	_layout_nav(portrait, vp)
	_layout_level_up()

func _layout_nav(portrait: bool, vp: Vector2) -> void:
	if nav_root == null:
		return
	var m := BrambleWorldPresentationConfig.HUD_SAFE_MARGIN
	var y := vp.y - 52 - m
	var x := vp.x * 0.5 - 150
	if portrait:
		y = vp.y - 58 - m
		x = vp.x * 0.5 - 150
	for i in range(nav_root.get_child_count()):
		var b := nav_root.get_child(i) as Control
		if b:
			b.position = Vector2(x + i * 76, y)

func _layout_level_up() -> void:
	if level_up_root:
		level_up_root.set_anchors_preset(Control.PRESET_FULL_RECT)

func _on_target_changed(state: Dictionary) -> void:
	var valid := bool(state.get("valid", false))
	target_root.visible = valid
	if not valid:
		return
	target_name.text = String(state.get("name", "Ziel"))
	target_hp.max_value = maxi(1, int(state.get("max_hp", 1)))
	target_hp.value = int(state.get("hp", 0))
	var dist := float(state.get("distance", 0.0))
	target_status.text = "HP %d/%d · %.0fm" % [int(state.get("hp", 0)), int(state.get("max_hp", 0)), dist]

func _on_inventory_changed(_items: Array) -> void:
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs:
		_on_character_changed(cs.get_character_view())

func _on_skill_cooldown(slot: int, remaining: float, total: float) -> void:
	if slot < 0 or slot >= skill_btns.size():
		return
	var btn := skill_btns[slot]
	var cd := skill_cd_labels[slot]
	if remaining <= 0.0:
		btn.modulate = Color.WHITE
		cd.visible = false
		return
	btn.modulate = Color(0.72, 0.72, 0.72, 0.92)
	cd.visible = true
	cd.text = "%.1f" % remaining

func _on_character_changed(view: Dictionary) -> void:
	if view.is_empty():
		return
	hp_bar.max_value = int(view.get("max_hp", 100))
	hp_bar.value = int(view.get("hp", 100))
	mp_bar.max_value = int(view.get("max_mp", 40))
	mp_bar.value = int(view.get("mp", 40))
	xp_bar.max_value = maxi(1, int(view.get("xp_to_next_level", 100)))
	xp_bar.value = int(view.get("xp", 0))
	level_badge.text = "Lv %d" % int(view.get("level", 1))
	stats_label.text = "%s  ·  %d Gold" % [
		String(view.get("display_name", "Hüter")),
		int(view.get("gold", 0)),
	]
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	if db:
		for i in range(mini(skill_btns.size(), 3)):
			var sid := ""
			if i < view.get("skillbar", []).size():
				sid = String(view.get("skillbar", [])[i])
			var skill := db.skill_by_id("adventurer", sid) if sid != "" else {}
			var icon_path := String(skill.get("icon", "ui/skills/skill_button.png"))
			if icon_path.length() <= 2:
				skill_icons[i].texture = BrambleWorldPresentationConfig.game_tex("ui/skills/skill_button.png")
			else:
				skill_icons[i].texture = BrambleWorldPresentationConfig.game_tex(icon_path)
			skill_btns[i].disabled = sid == ""

func _on_level_up(new_level: int, rewards: Dictionary) -> void:
	show_level_up(new_level, rewards)

func show_level_up(new_level: int, rewards: Dictionary = {}) -> void:
	if level_up_root == null:
		return
	level_up_level.text = "Level %d" % new_level
	var stat_pts := int(rewards.get("stat_points", 2))
	var skill_pts := int(rewards.get("skill_points", 1))
	level_up_rewards.text = "+%d Stat  ·  +%d Skill" % [stat_pts, skill_pts]
	level_up_root.visible = true
	level_up_time = 2.8

func _on_nav(kind: String) -> void:
	var ui = get_tree().get_first_node_in_group("production_rpg_ui")
	match kind:
		"inventory":
			if ui:
				ui.toggle_inventory()
		"character":
			if ui:
				ui.toggle_character()
		"quest":
			show_toast("Quest-Tracker aktiv")
		"social":
			show_toast("Sozial · bald verfügbar")

func _process(delta: float) -> void:
	if toast_time > 0.0:
		toast_time -= delta
		if toast_time <= 0.0:
			toast.visible = false
	if level_up_time > 0.0:
		level_up_time -= delta
		if level_up_time <= 0.0 and level_up_root:
			level_up_root.visible = false

func _on_quest_changed(title: String, text: String) -> void:
	quest_title.text = title
	quest_text.text = text

func _on_stats_changed(hp: int, max_hp: int, level: int, xp: int, gold: int) -> void:
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs:
		_on_character_changed(cs.get_character_view())
		return
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	mp_bar.max_value = 100
	mp_bar.value = clampi(100 - level * 3, 35, 100)
	level_badge.text = "Lv %d" % level
	stats_label.text = "%d Gold" % gold

func show_dialogue(title: String, text: String) -> void:
	dialogue_title.text = title
	dialogue_text.text = text
	dialogue.position = Vector2(40, get_viewport().get_visible_rect().size.y * 0.52)
	dialogue.visible = true

func show_toast(text: String) -> void:
	if text.begins_with("LEVEL UP"):
		return
	toast.text = text
	toast.position = Vector2(BrambleWorldPresentationConfig.HUD_SAFE_MARGIN, 112)
	toast.add_theme_font_size_override("font_size", 13)
	toast.visible = true
	toast_time = 2.4
