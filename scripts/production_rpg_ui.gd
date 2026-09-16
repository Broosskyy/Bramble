class_name BrambleProductionRpgUi
extends CanvasLayer

enum Screen { INVENTORY, CHARACTER }

const RARITY_COLORS := {
	"COMMON": Color("#d8d0c0"),
	"UNCOMMON": Color("#7ecf7a"),
	"RARE": Color("#6db5ff"),
	"EPIC": Color("#c88cff"),
	"LEGENDARY": Color("#ffb84d"),
}

var _root: Control
var _panel: PanelContainer
var _left: VBoxContainer
var _right: VBoxContainer
var _detail: VBoxContainer
var _tabs: HBoxContainer
var _category_row: HBoxContainer
var _grid: GridContainer
var _char_summary: Label
var _stat_rows: VBoxContainer
var _skill_row: HBoxContainer
var _visible_screen := Screen.INVENTORY
var _category := "ALL"
var _selected_item_id := ""
var _portrait := false

func _ready() -> void:
	add_to_group("production_rpg_ui")
	layer = 20
	_build_ui()
	hide_panel()
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs:
		cs.character_changed.connect(_refresh)
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		orient.orientation_changed.connect(func(mode): _apply_layout(mode == "portrait"))

func show_inventory() -> void:
	_visible_screen = Screen.INVENTORY
	show_panel()

func show_character() -> void:
	_visible_screen = Screen.CHARACTER
	show_panel()

func toggle_inventory() -> void:
	if visible and _visible_screen == Screen.INVENTORY:
		hide_panel()
	else:
		show_inventory()

func toggle_character() -> void:
	if visible and _visible_screen == Screen.CHARACTER:
		hide_panel()
	else:
		show_character()

func hide_panel() -> void:
	visible = false

func show_panel() -> void:
	visible = true
	_refresh()
	_apply_layout(_portrait)

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)
	_panel = PanelContainer.new()
	_root.add_child(_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	_panel.add_child(margin)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	margin.add_child(body)
	_left = VBoxContainer.new()
	_left.custom_minimum_size = Vector2(280, 420)
	body.add_child(_left)
	var left_bg := _tex("ui/character/character_stats_panel.png", Vector2(280, 420))
	_left.add_child(left_bg)
	_char_summary = Label.new()
	_char_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_char_summary.add_theme_font_size_override("font_size", 12)
	_left.add_child(_char_summary)
	_stat_rows = VBoxContainer.new()
	_left.add_child(_stat_rows)
	_right = VBoxContainer.new()
	_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_right)
	var right_bg := _tex("ui/inventory/kit76_inventory_panel.png", Vector2(420, 420))
	_right.add_child(right_bg)
	_tabs = HBoxContainer.new()
	_right.add_child(_tabs)
	for label in ["Inventar", "Charakter"]:
		var b := Button.new()
		b.text = label
		b.pressed.connect(func(): _on_tab(label))
		_tabs.add_child(b)
	_category_row = HBoxContainer.new()
	_right.add_child(_category_row)
	for cat in ["ALL", "WEAPONS", "ARMOR", "ACCESSORIES", "CONSUMABLES", "MATERIALS", "QUEST"]:
		var b := Button.new()
		b.text = cat.substr(0, 3)
		b.tooltip_text = cat
		b.pressed.connect(func(): _set_category(cat))
		_category_row.add_child(b)
	_grid = GridContainer.new()
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	_right.add_child(_grid)
	_detail = VBoxContainer.new()
	body.add_child(_detail)
	var detail_bg := _tex("ui/inventory/item_detail_tooltip.png", Vector2(220, 420))
	_detail.add_child(detail_bg)
	_skill_row = HBoxContainer.new()
	_left.add_child(_skill_row)
	var close := Button.new()
	close.text = "Schließen"
	close.pressed.connect(hide_panel)
	_right.add_child(close)

func _on_tab(label: String) -> void:
	if label == "Charakter":
		show_character()
	else:
		show_inventory()

func _set_category(cat: String) -> void:
	_category = cat
	_refresh()

func _apply_layout(portrait: bool) -> void:
	_portrait = portrait
	var vp := get_viewport().get_visible_rect().size
	if portrait:
		_panel.position = Vector2(12, 72)
		_panel.size = Vector2(vp.x - 24, vp.y - 140)
	else:
		_panel.position = Vector2(48, 48)
		_panel.size = Vector2(vp.x - 96, vp.y - 96)

func _refresh(_view: Dictionary = {}) -> void:
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs == null:
		return
	var view: Dictionary = cs.get_character_view()
	_char_summary.text = "%s  ·  Lv %d\nXP %d / %d  ·  %d G\nHP %d/%d  ·  MP %d/%d\nStat-Punkte: %d  ·  Skill-Punkte: %d" % [
		view.get("display_name", "Hüter"),
		view.get("level", 1),
		view.get("xp", 0), view.get("xp_to_next_level", 100),
		view.get("gold", 0),
		view.get("hp", 0), view.get("max_hp", 0),
		view.get("mp", 0), view.get("max_mp", 0),
		view.get("available_stat_points", 0),
		view.get("available_skill_points", 0),
	]
	_rebuild_stats(view)
	_rebuild_skills(view)
	_rebuild_grid(view)
	_rebuild_detail(view)

func _rebuild_stats(view: Dictionary) -> void:
	for c in _stat_rows.get_children():
		c.queue_free()
	var derived: Dictionary = view.get("derived_stats", {})
	for label_text in ["Angriff", "Magie", "Vert.", "Mag.V.", "Tempo"]:
		var key_map := {"Angriff": "physical_attack", "Magie": "magic_attack", "Vert.": "physical_defense", "Mag.V.": "magic_defense", "Tempo": "move_speed"}
		var l := Label.new()
		l.text = "%s: %s" % [label_text, str(derived.get(key_map[label_text], 0))]
		l.add_theme_font_size_override("font_size", 11)
		_stat_rows.add_child(l)
	if int(view.get("available_stat_points", 0)) > 0:
		var row := HBoxContainer.new()
		for stat in ["vitality", "strength", "defense", "magic", "resistance", "speed"]:
			var b := Button.new()
			b.text = stat.substr(0, 3)
			b.tooltip_text = stat
			b.pressed.connect(func(): _allocate(stat))
			row.add_child(b)
		_stat_rows.add_child(row)

func _allocate(stat: String) -> void:
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs and cs.allocate_stat(stat):
		_refresh()

func _rebuild_skills(view: Dictionary) -> void:
	for c in _skill_row.get_children():
		c.queue_free()
	var labels: Array = []
	for i in range(3):
		var sid := ""
		if i < view.get("skillbar", []).size():
			sid = String(view.get("skillbar", [])[i])
		labels.append("S%d:%s" % [i + 1, sid if sid != "" else "-"])
	var l := Label.new()
	l.text = "Skills: " + ", ".join(labels)
	l.add_theme_font_size_override("font_size", 10)
	_skill_row.add_child(l)

func _rebuild_grid(view: Dictionary) -> void:
	for c in _grid.get_children():
		c.queue_free()
	for entry in view.get("inventory", []):
		if not _category_match(entry):
			continue
		var b := Button.new()
		b.custom_minimum_size = Vector2(52, 52)
		b.text = "%s\nx%d" % [String(entry.get("display_name", "?")).substr(0, 8), int(entry.get("quantity", 1))]
		b.modulate = RARITY_COLORS.get(String(entry.get("rarity", "COMMON")), Color.WHITE)
		var item_id := String(entry.get("item_id", ""))
		b.pressed.connect(func(): select_item(item_id))
		_grid.add_child(b)

func _category_match(entry: Dictionary) -> bool:
	if _category == "ALL":
		return true
	var cat := String(entry.get("category", "MISC"))
	match _category:
		"WEAPONS": return cat == "EQUIPMENT" and String(entry.get("allowed_slot", "")) == "weapon"
		"ARMOR": return cat == "EQUIPMENT" and String(entry.get("allowed_slot", "")) in ["armor", "gloves", "boots", "head"]
		"ACCESSORIES": return cat == "EQUIPMENT" and String(entry.get("allowed_slot", "")).begins_with("accessory")
		"CONSUMABLES": return cat == "CONSUMABLE"
		"MATERIALS": return cat == "MATERIAL"
		"QUEST": return cat == "QUEST"
	return true

func select_item(item_id: String) -> void:
	_selected_item_id = item_id
	_refresh()

func _rebuild_detail(view: Dictionary) -> void:
	while _detail.get_child_count() > 1:
		_detail.get_child(_detail.get_child_count() - 1).queue_free()
	if _selected_item_id == "":
		return
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	var item := db.item_data(_selected_item_id) if db else {}
	if item.is_empty():
		return
	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size = Vector2(200, 180)
	var mods: Dictionary = item.get("stat_modifiers", {})
	var mod_parts: PackedStringArray = []
	for k in mods.keys():
		mod_parts.append("%s+%s" % [k, str(mods[k])])
	var mod_text := ", ".join(mod_parts)
	info.text = "%s\n[%s]\n%s\n\n%s\n\nLv %d  ·  %d G" % [
		item.get("display_name", _selected_item_id),
		item.get("rarity", "COMMON"),
		item.get("description", ""),
		mod_text,
		int(item.get("required_level", 1)),
		int(item.get("sell_value", 0)),
	]
	_detail.add_child(info)
	if String(item.get("category", "")) == "EQUIPMENT":
		var slot := String(item.get("allowed_slot", ""))
		var equipped_id := String(view.get("equipment", {}).get(slot, ""))
		if equipped_id != "" and equipped_id != _selected_item_id:
			var eq_item := db.item_data(equipped_id)
			var cmp := Label.new()
			cmp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cmp.add_theme_font_size_override("font_size", 10)
			cmp.text = _comparison_text(eq_item, item)
			_detail.add_child(cmp)
		elif equipped_id == _selected_item_id:
			var worn := Label.new()
			worn.text = "Aktuell ausgerüstet"
			worn.add_theme_font_size_override("font_size", 10)
			_detail.add_child(worn)
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if String(item.get("category", "")) == "EQUIPMENT":
		var equip := Button.new()
		equip.text = "Ausrüsten"
		equip.pressed.connect(func():
			if cs: cs.equip_from_inventory(_selected_item_id)
		)
		_detail.add_child(equip)
	elif String(item.get("category", "")) == "CONSUMABLE":
		var use := Button.new()
		use.text = "Benutzen"
		use.pressed.connect(func():
			if cs: cs.use_consumable(_selected_item_id)
		)
		_detail.add_child(use)

func _comparison_text(current: Dictionary, selected: Dictionary) -> String:
	var lines: PackedStringArray = ["Vergleich · AKTUELL vs GEWÄHLT"]
	var cur_mods: Dictionary = current.get("stat_modifiers", {})
	var sel_mods: Dictionary = selected.get("stat_modifiers", {})
	var keys: Dictionary = {}
	for k in cur_mods.keys():
		keys[k] = true
	for k in sel_mods.keys():
		keys[k] = true
	for k in keys.keys():
		var cur := int(cur_mods.get(k, 0))
		var sel := int(sel_mods.get(k, 0))
		var delta := sel - cur
		var sign := "+" if delta >= 0 else ""
		lines.append("%s: %d → %d (%s%d)" % [k, cur, sel, sign, delta])
	return "\n".join(lines)

func _tex(path: String, size: Vector2) -> TextureRect:
	var t := TextureRect.new()
	t.texture = BrambleWorldPresentationConfig.game_tex(path)
	t.custom_minimum_size = size
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	return t
