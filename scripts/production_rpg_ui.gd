class_name BrambleProductionRpgUi
extends CanvasLayer

enum Screen { INVENTORY, CHARACTER }
enum PortraitTab { BAG, CHAR, EQUIP, DETAIL }

const RARITY_COLORS := {
	"COMMON": Color("#d8d0c0"),
	"UNCOMMON": Color("#7ecf7a"),
	"RARE": Color("#6db5ff"),
	"EPIC": Color("#c88cff"),
	"LEGENDARY": Color("#ffb84d"),
}

const EQUIP_SLOTS := [
	{"key": "head", "label": "Kopf"},
	{"key": "weapon", "label": "Waffe"},
	{"key": "armor", "label": "Rüstung"},
	{"key": "gloves", "label": "Hand"},
	{"key": "boots", "label": "Stiefel"},
	{"key": "accessory_1", "label": "Acc 1"},
	{"key": "accessory_2", "label": "Acc 2"},
]

const STAT_LABELS := {
	"physical_attack": "Angriff",
	"magic_attack": "Magie",
	"physical_defense": "Verteidigung",
	"magic_defense": "Mag.Verteidigung",
	"move_speed": "Tempo",
}

const BASE_STAT_LABELS := {
	"vitality": "VIT",
	"strength": "STR",
	"defense": "DEF",
	"magic": "MAG",
	"resistance": "RES",
	"speed": "SPD",
}

var _root: Control
var _dim: ColorRect
var _landscape: Control
var _portrait: Control
var _landscape_grid: GridContainer
var _portrait_grid: GridContainer
var _landscape_detail: VBoxContainer
var _portrait_detail: VBoxContainer
var _landscape_equip: Dictionary = {}
var _portrait_equip: Dictionary = {}
var _landscape_identity: Label
var _portrait_identity: Label
var _landscape_hp: ProgressBar
var _landscape_mp: ProgressBar
var _landscape_xp: ProgressBar
var _portrait_hp: ProgressBar
var _portrait_mp: ProgressBar
var _portrait_xp: ProgressBar
var _landscape_stats: VBoxContainer
var _portrait_stats: VBoxContainer
var _landscape_char_body: VBoxContainer
var _portrait_char_body: VBoxContainer
var _landscape_capacity: Label
var _portrait_capacity: Label
var _landscape_center_stack: VBoxContainer
var _portrait_content: Control
var _portrait_tab_row: HBoxContainer
var _category_landscape: HBoxContainer
var _category_portrait: HBoxContainer
var _landscape_tab_inv: Button
var _landscape_tab_chr: Button

var _visible_screen := Screen.INVENTORY
var _portrait_tab := PortraitTab.BAG
var _category := "ALL"
var _selected_item_id := ""
var _portrait_mode := false

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
	_portrait_tab = PortraitTab.BAG
	show_panel()

func show_character() -> void:
	_visible_screen = Screen.CHARACTER
	_portrait_tab = PortraitTab.CHAR
	show_panel()

func toggle_inventory() -> void:
	if visible and _visible_screen == Screen.INVENTORY and not _portrait_mode:
		hide_panel()
	elif visible and _portrait_mode and _portrait_tab == PortraitTab.BAG:
		hide_panel()
	else:
		show_inventory()

func toggle_character() -> void:
	if visible and _visible_screen == Screen.CHARACTER and not _portrait_mode:
		hide_panel()
	elif visible and _portrait_mode and _portrait_tab == PortraitTab.CHAR:
		hide_panel()
	else:
		show_character()

func hide_panel() -> void:
	visible = false

func show_panel() -> void:
	visible = true
	_apply_layout(_viewport_portrait())
	_refresh()

func select_item(item_id: String) -> void:
	_selected_item_id = item_id
	if _viewport_portrait():
		_portrait_tab = PortraitTab.DETAIL
	_refresh()

func _viewport_portrait() -> bool:
	var size := get_viewport().get_visible_rect().size
	var win := get_window()
	if win:
		var ws := win.size
		if ws.x > 0 and ws.y > 0:
			size = ws
	return size.y > size.x

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.03, 0.06, 0.62)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_dim)
	_landscape = _build_landscape_panel()
	_root.add_child(_landscape)
	_portrait = _build_portrait_panel()
	_root.add_child(_portrait)

func _build_landscape_panel() -> Control:
	var panel := Control.new()
	panel.visible = true
	var shell := _framed_panel(Vector2(920, 520), "ui/inventory/kit76_inventory_panel.png")
	shell.position = Vector2(48, 40)
	panel.add_child(shell)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 18
	body.offset_top = 16
	body.offset_right = -18
	body.offset_bottom = -16
	shell.add_child(body)
	var left := _build_character_column(true)
	body.add_child(left)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	body.add_child(center)
	_landscape_center_stack = center
	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 6)
	center.add_child(tab_row)
	_landscape_tab_inv = _tab_button("Inventar", func(): _set_screen(Screen.INVENTORY))
	_landscape_tab_chr = _tab_button("Charakter", func(): _set_screen(Screen.CHARACTER))
	tab_row.add_child(_landscape_tab_inv)
	tab_row.add_child(_landscape_tab_chr)
	_category_landscape = HBoxContainer.new()
	_category_landscape.add_theme_constant_override("separation", 4)
	center.add_child(_category_landscape)
	for cat in ["ALL", "WEAPONS", "ARMOR", "ACCESSORIES", "CONSUMABLES", "MATERIALS", "QUEST"]:
		_category_landscape.add_child(_category_button(cat, _category_landscape))
	_landscape_grid = _make_grid()
	center.add_child(_landscape_grid)
	_landscape_capacity = _label("", 12)
	center.add_child(_landscape_capacity)
	_landscape_char_body = VBoxContainer.new()
	_landscape_char_body.visible = false
	_landscape_char_body.add_theme_constant_override("separation", 6)
	center.add_child(_landscape_char_body)
	var close := _action_button("Schließen", hide_panel)
	close.custom_minimum_size = Vector2(120, 40)
	center.add_child(close)
	_landscape_detail = VBoxContainer.new()
	_landscape_detail.custom_minimum_size = Vector2(240, 0)
	body.add_child(_landscape_detail)
	var detail_frame := _framed_panel(Vector2(240, 480), "ui/inventory/item_detail_tooltip.png")
	_landscape_detail.add_child(detail_frame)
	var detail_content := VBoxContainer.new()
	detail_content.set_anchors_preset(Control.PRESET_FULL_RECT)
	detail_content.offset_left = 12
	detail_content.offset_top = 12
	detail_content.offset_right = -12
	detail_content.offset_bottom = -12
	detail_content.add_theme_constant_override("separation", 6)
	detail_frame.add_child(detail_content)
	return panel

func _build_portrait_panel() -> Control:
	var panel := Control.new()
	panel.visible = false
	var shell := _framed_panel(Vector2(0, 0), "ui/character/character_panel.png")
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.offset_left = 10
	shell.offset_top = 56
	shell.offset_right = -10
	shell.offset_bottom = -72
	panel.add_child(shell)
	var outer := VBoxContainer.new()
	outer.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer.offset_left = 14
	outer.offset_top = 12
	outer.offset_right = -14
	outer.offset_bottom = -12
	outer.add_theme_constant_override("separation", 8)
	shell.add_child(outer)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	outer.add_child(top)
	var mini_portrait := TextureRect.new()
	mini_portrait.texture = _char_tex()
	mini_portrait.custom_minimum_size = Vector2(56, 72)
	mini_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	mini_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top.add_child(mini_portrait)
	var bars := VBoxContainer.new()
	bars.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars.add_theme_constant_override("separation", 4)
	top.add_child(bars)
	_portrait_identity = _label("Hüter · Lv 1", 15)
	bars.add_child(_portrait_identity)
	_portrait_hp = _bar(Color("#c44"), 220.0)
	bars.add_child(_portrait_hp)
	_portrait_mp = _bar(Color("#58a"), 220.0)
	bars.add_child(_portrait_mp)
	_portrait_xp = _bar(Color("#7a5"), 220.0)
	bars.add_child(_portrait_xp)
	_portrait_tab_row = HBoxContainer.new()
	_portrait_tab_row.add_theme_constant_override("separation", 6)
	outer.add_child(_portrait_tab_row)
	for spec in [["Tasche", PortraitTab.BAG], ["Charakter", PortraitTab.CHAR], ["Ausrüstung", PortraitTab.EQUIP], ["Detail", PortraitTab.DETAIL]]:
		var b := _tab_button(spec[0], func(): _set_portrait_tab(spec[1]))
		b.custom_minimum_size = Vector2(72, 44)
		_portrait_tab_row.add_child(b)
	_portrait_content = Control.new()
	_portrait_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(_portrait_content)
	var bag_body := VBoxContainer.new()
	bag_body.name = "BagBody"
	bag_body.set_anchors_preset(Control.PRESET_FULL_RECT)
	bag_body.add_theme_constant_override("separation", 6)
	_portrait_content.add_child(bag_body)
	_category_portrait = HBoxContainer.new()
	_category_portrait.add_theme_constant_override("separation", 3)
	bag_body.add_child(_category_portrait)
	for cat in ["ALL", "WEAPONS", "ARMOR", "ACCESSORIES", "CONSUMABLES", "MATERIALS", "QUEST"]:
		var cb := _category_button(cat, _category_portrait)
		cb.custom_minimum_size = Vector2(44, 36)
		_category_portrait.add_child(cb)
	_portrait_grid = _make_grid()
	_portrait_grid.columns = 5
	bag_body.add_child(_portrait_grid)
	_portrait_capacity = _label("", 12)
	bag_body.add_child(_portrait_capacity)
	var char_body := VBoxContainer.new()
	char_body.name = "CharBody"
	char_body.visible = false
	char_body.set_anchors_preset(Control.PRESET_FULL_RECT)
	_portrait_content.add_child(char_body)
	_portrait_stats = VBoxContainer.new()
	char_body.add_child(_portrait_stats)
	var equip_body := _build_character_column(false)
	equip_body.name = "EquipBody"
	equip_body.visible = false
	equip_body.set_anchors_preset(Control.PRESET_FULL_RECT)
	_portrait_content.add_child(equip_body)
	_portrait_detail = VBoxContainer.new()
	_portrait_detail.name = "DetailBody"
	_portrait_detail.visible = false
	_portrait_detail.set_anchors_preset(Control.PRESET_FULL_RECT)
	_portrait_content.add_child(_portrait_detail)
	var close_row := HBoxContainer.new()
	close_row.alignment = BoxContainer.ALIGNMENT_CENTER
	outer.add_child(close_row)
	close_row.add_child(_action_button("Schließen", hide_panel))
	return panel

func _build_character_column(landscape: bool) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(240 if landscape else 0, 0)
	col.add_theme_constant_override("separation", 6)
	var frame := _framed_panel(Vector2(240, 300 if landscape else 260), "ui/character/character_stats_panel.png")
	col.add_child(frame)
	var inner := VBoxContainer.new()
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.offset_left = 12
	inner.offset_top = 10
	inner.offset_right = -12
	inner.offset_bottom = -10
	inner.add_theme_constant_override("separation", 6)
	frame.add_child(inner)
	var portrait_row := CenterContainer.new()
	inner.add_child(portrait_row)
	var portrait := TextureRect.new()
	portrait.texture = _char_tex()
	portrait.custom_minimum_size = Vector2(96, 120)
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_row.add_child(portrait)
	var equip_grid := GridContainer.new()
	equip_grid.columns = 4
	equip_grid.add_theme_constant_override("h_separation", 4)
	equip_grid.add_theme_constant_override("v_separation", 4)
	inner.add_child(equip_grid)
	var equip_map: Dictionary = {}
	if landscape:
		_landscape_equip = equip_map
	else:
		_portrait_equip = equip_map
	for spec in EQUIP_SLOTS:
		var slot := _equip_slot(spec.key, spec.label)
		equip_grid.add_child(slot.root)
		equip_map[spec.key] = slot
	if landscape:
		_landscape_identity = _label("Hüter · Lv 1", 14)
		inner.add_child(_landscape_identity)
		_landscape_hp = _bar(Color("#c44"))
		inner.add_child(_landscape_hp)
		_landscape_mp = _bar(Color("#58a"))
		inner.add_child(_landscape_mp)
		_landscape_xp = _bar(Color("#7a5"))
		inner.add_child(_landscape_xp)
		_landscape_stats = VBoxContainer.new()
		inner.add_child(_landscape_stats)
	else:
		_portrait_char_body = inner
	return col

func _make_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 6
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	return grid

func _set_screen(screen: Screen) -> void:
	_visible_screen = screen
	_refresh()

func _set_portrait_tab(tab: PortraitTab) -> void:
	_portrait_tab = tab
	_refresh()

func _set_category(cat: String) -> void:
	_category = cat
	_refresh()

func _apply_layout(portrait: bool) -> void:
	_portrait_mode = portrait
	var vp := get_viewport().get_visible_rect().size
	_landscape.visible = not portrait
	_portrait.visible = portrait
	if portrait:
		_portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
		_portrait.set_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		_landscape.set_anchors_preset(Control.PRESET_FULL_RECT)
		_landscape.set_offsets_preset(Control.PRESET_FULL_RECT)
		var shell := _landscape.get_child(0) as Control
		if shell:
			shell.position = Vector2(maxf(24.0, (vp.x - 920.0) * 0.5), maxf(24.0, (vp.y - 520.0) * 0.5))

func _refresh(_view: Dictionary = {}) -> void:
	var portrait := _viewport_portrait()
	if portrait != _portrait_mode:
		_apply_layout(portrait)
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs == null:
		return
	var view: Dictionary = cs.get_character_view()
	_update_identity(view)
	_update_bars(view)
	_update_equipment(view)
	_update_tabs()
	if _portrait_mode:
		_update_portrait_visibility()
		_rebuild_grid(_portrait_grid, view)
		_rebuild_detail(_portrait_detail, view)
		_rebuild_stats(_portrait_stats, view, true)
		_portrait_capacity.text = _capacity_text(view)
	else:
		_landscape_grid.visible = _visible_screen == Screen.INVENTORY
		_category_landscape.visible = _visible_screen == Screen.INVENTORY
		_landscape_capacity.visible = _visible_screen == Screen.INVENTORY
		_landscape_char_body.visible = _visible_screen == Screen.CHARACTER
		if _visible_screen == Screen.INVENTORY:
			_rebuild_grid(_landscape_grid, view)
			_landscape_capacity.text = _capacity_text(view)
		else:
			_rebuild_stats(_landscape_char_body, view, false)
		_rebuild_detail(_landscape_detail, view)
		_rebuild_stats(_landscape_stats, view, true)

func _update_identity(view: Dictionary) -> void:
	var text := "%s  ·  Lv %d\n%d Gold" % [
		view.get("display_name", "Hüter"),
		view.get("level", 1),
		view.get("gold", 0),
	]
	if _landscape_identity:
		_landscape_identity.text = text
	if _portrait_identity:
		_portrait_identity.text = text.replace("\n", "  ·  ")

func _update_bars(view: Dictionary) -> void:
	for pair in [[_landscape_hp, _landscape_mp, _landscape_xp], [_portrait_hp, _portrait_mp, _portrait_xp]]:
		if pair[0] == null:
			continue
		pair[0].max_value = int(view.get("max_hp", 100))
		pair[0].value = int(view.get("hp", 100))
		pair[1].max_value = int(view.get("max_mp", 40))
		pair[1].value = int(view.get("mp", 40))
		pair[2].max_value = maxi(1, int(view.get("xp_to_next_level", 100)))
		pair[2].value = int(view.get("xp", 0))

func _update_equipment(view: Dictionary) -> void:
	var equipment: Dictionary = view.get("equipment", {})
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	for slot_map in [_landscape_equip, _portrait_equip]:
		for key in slot_map.keys():
			var slot: Dictionary = slot_map[key]
			var item_id := String(equipment.get(key, ""))
			var item := db.item_data(item_id) if db and item_id != "" else {}
			_set_slot_icon(slot, item, item_id)
			if slot.has("label"):
				slot.label.text = slot.label.text.split("\n")[0]

func _update_tabs() -> void:
	if _landscape_tab_inv:
		_landscape_tab_inv.disabled = _visible_screen == Screen.INVENTORY
	if _landscape_tab_chr:
		_landscape_tab_chr.disabled = _visible_screen == Screen.CHARACTER

func _update_portrait_visibility() -> void:
	var bag := _portrait_content.get_node_or_null("BagBody")
	var char_body := _portrait_content.get_node_or_null("CharBody")
	var equip_body := _portrait_content.get_node_or_null("EquipBody")
	if bag:
		bag.visible = _portrait_tab == PortraitTab.BAG
	if char_body:
		char_body.visible = _portrait_tab == PortraitTab.CHAR
	if equip_body:
		equip_body.visible = _portrait_tab == PortraitTab.EQUIP
	if _portrait_detail:
		_portrait_detail.visible = _portrait_tab == PortraitTab.DETAIL

func _capacity_text(view: Dictionary) -> String:
	var used: int = view.get("inventory", []).size()
	var cap := int(view.get("inventory_capacity", 28))
	return "Belegt %d / %d" % [used, cap]

func _rebuild_stats(target: VBoxContainer, view: Dictionary, compact: bool) -> void:
	for c in target.get_children():
		c.queue_free()
	var derived: Dictionary = view.get("derived_stats", {})
	for key in STAT_LABELS.keys():
		var l := _label("%s: %s" % [STAT_LABELS[key], str(derived.get(key, 0))], 13 if compact else 14)
		target.add_child(l)
	var base: Dictionary = view.get("base_stats", {})
	if not compact:
		target.add_child(_label("— Primärwerte —", 12))
		for key in BASE_STAT_LABELS.keys():
			target.add_child(_label("%s: %d" % [BASE_STAT_LABELS[key], int(base.get(key, 0))], 13))
	if int(view.get("available_stat_points", 0)) > 0:
		target.add_child(_label("Stat-Punkte: %d" % int(view.get("available_stat_points", 0)), 13))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		for stat in BASE_STAT_LABELS.keys():
			var b := _action_button(BASE_STAT_LABELS[stat], func(): _allocate(stat))
			b.custom_minimum_size = Vector2(44, 44)
			row.add_child(b)
		target.add_child(row)

func _allocate(stat: String) -> void:
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs and cs.allocate_stat(stat):
		_refresh()

func _rebuild_grid(grid: GridContainer, view: Dictionary) -> void:
	for c in grid.get_children():
		c.queue_free()
	for entry in view.get("inventory", []):
		if not _category_match(entry):
			continue
		grid.add_child(_inventory_slot(entry))

func _inventory_slot(entry: Dictionary) -> Control:
	var item_id := String(entry.get("item_id", ""))
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	var item := db.item_data(item_id) if db else entry
	var root := Control.new()
	root.custom_minimum_size = Vector2(56, 56)
	var bg := TextureRect.new()
	bg.texture = _tex("ui/touch/item_slot.png")
	bg.custom_minimum_size = Vector2(56, 56)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(bg)
	var icon := TextureRect.new()
	icon.texture = _item_icon(item)
	icon.custom_minimum_size = Vector2(44, 44)
	icon.position = Vector2(6, 6)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(icon)
	var qty := int(entry.get("quantity", 1))
	if qty > 1:
		var badge := _label("x%d" % qty, 11)
		badge.position = Vector2(30, 36)
		badge.add_theme_color_override("font_color", Color.WHITE)
		root.add_child(badge)
	var rarity := String(entry.get("rarity", item.get("rarity", "COMMON")))
	bg.modulate = RARITY_COLORS.get(rarity, Color.WHITE)
	if item_id == _selected_item_id:
		var sel := ColorRect.new()
		sel.color = Color(1.0, 0.86, 0.35, 0.28)
		sel.set_anchors_preset(Control.PRESET_FULL_RECT)
		sel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(sel)
	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.pressed.connect(func(): select_item(item_id))
	root.add_child(btn)
	return root

func _rebuild_detail(host: VBoxContainer, view: Dictionary) -> void:
	var content_parent := host
	if host.get_child_count() > 0:
		var frame := host.get_child(0) as Control
		if frame and frame.get_child_count() >= 3:
			content_parent = frame.get_child(2) as VBoxContainer
		elif frame and frame.get_child_count() > 0:
			content_parent = frame
	for c in content_parent.get_children():
		c.queue_free()
	if _selected_item_id == "":
		var hint := _label("Wähle ein Item in der Tasche.", 13)
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content_parent.add_child(hint)
		return
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	var item := db.item_data(_selected_item_id) if db else {}
	if item.is_empty():
		return
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	content_parent.add_child(header)
	var icon := TextureRect.new()
	icon.texture = _item_icon(item)
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header.add_child(icon)
	var title_box := VBoxContainer.new()
	header.add_child(title_box)
	var rarity := String(item.get("rarity", "COMMON"))
	var name_l := _label(String(item.get("display_name", _selected_item_id)), 16)
	name_l.add_theme_color_override("font_color", RARITY_COLORS.get(rarity, Color.WHITE))
	title_box.add_child(name_l)
	title_box.add_child(_label("[%s]" % rarity, 12))
	title_box.add_child(_label("Lv %d" % int(item.get("required_level", 1)), 12))
	var desc := _label(String(item.get("description", "")), 13)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_parent.add_child(desc)
	var mods: Dictionary = item.get("stat_modifiers", {})
	if not mods.is_empty():
		var mod_lines: PackedStringArray = []
		for k in mods.keys():
			mod_lines.append("%s +%s" % [k, str(mods[k])])
		var mod_l := _label("\n".join(mod_lines), 12)
		mod_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_parent.add_child(mod_l)
	if String(item.get("category", "")) == "EQUIPMENT":
		var slot := String(item.get("allowed_slot", ""))
		var equipped_id := String(view.get("equipment", {}).get(slot, ""))
		if equipped_id != "" and equipped_id != _selected_item_id:
			var eq_item := db.item_data(equipped_id)
			var cmp := _label(_comparison_text(eq_item, item), 12)
			cmp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			content_parent.add_child(cmp)
		elif equipped_id == _selected_item_id:
			content_parent.add_child(_label("Aktuell ausgerüstet", 12))
	var cs = get_tree().get_first_node_in_group("character_state_service")
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	content_parent.add_child(actions)
	if String(item.get("category", "")) == "EQUIPMENT":
		actions.add_child(_action_button("Ausrüsten", func():
			if cs:
				cs.equip_from_inventory(_selected_item_id)
		))
	elif String(item.get("category", "")) == "CONSUMABLE":
		actions.add_child(_action_button("Benutzen", func():
			if cs:
				cs.use_consumable(_selected_item_id)
		))

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

func _category_match(entry: Dictionary) -> bool:
	if _category == "ALL":
		return true
	var cat := String(entry.get("category", "MISC"))
	match _category:
		"WEAPONS":
			return cat == "EQUIPMENT" and String(entry.get("allowed_slot", "")) == "weapon"
		"ARMOR":
			return cat == "EQUIPMENT" and String(entry.get("allowed_slot", "")) in ["armor", "gloves", "boots", "head"]
		"ACCESSORIES":
			return cat == "EQUIPMENT" and String(entry.get("allowed_slot", "")).begins_with("accessory")
		"CONSUMABLES":
			return cat == "CONSUMABLE"
		"MATERIALS":
			return cat == "MATERIAL"
		"QUEST":
			return cat == "QUEST"
	return true

func _equip_slot(slot_key: String, slot_label: String) -> Dictionary:
	var root := Control.new()
	root.custom_minimum_size = Vector2(52, 52)
	var bg := TextureRect.new()
	bg.texture = _tex("ui/touch/item_slot.png")
	bg.custom_minimum_size = Vector2(52, 52)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(bg)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(40, 40)
	icon.position = Vector2(6, 4)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(icon)
	var label := _label(slot_label, 9)
	label.position = Vector2(2, 38)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(48, 12)
	root.add_child(label)
	return {"root": root, "icon": icon, "bg": bg, "label": label}

func _set_slot_icon(slot: Dictionary, item: Dictionary, item_id: String) -> void:
	var icon: TextureRect = slot.icon
	if item_id == "":
		icon.texture = null
		icon.modulate = Color(0.55, 0.52, 0.48, 0.35)
		return
	icon.texture = _item_icon(item)
	icon.modulate = Color.WHITE
	var rarity := String(item.get("rarity", "COMMON"))
	slot.bg.modulate = RARITY_COLORS.get(rarity, Color.WHITE)

func _item_icon(item: Dictionary) -> Texture2D:
	var path := String(item.get("icon", ""))
	if path == "":
		return _tex("ui/inventory/inventory.png")
	return _tex(path)

func _char_tex() -> Texture2D:
	return _tex("characters/base/male/directions/front.png")

func _framed_panel(size: Vector2, tex_path: String) -> Control:
	var root := Control.new()
	if size.x > 0:
		root.custom_minimum_size = size
		root.size = size
	var bg := TextureRect.new()
	bg.texture = _tex(tex_path)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.04, 0.03, 0.42)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)
	return root

func _tab_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(88, 40)
	b.add_theme_font_size_override("font_size", 13)
	b.pressed.connect(cb)
	return b

func _category_button(cat: String, _row: HBoxContainer) -> Button:
	var b := Button.new()
	b.text = cat.substr(0, 3)
	b.tooltip_text = cat
	b.custom_minimum_size = Vector2(44, 36)
	b.add_theme_font_size_override("font_size", 11)
	b.pressed.connect(func(): _set_category(cat))
	return b

func _action_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(96, 44)
	b.add_theme_font_size_override("font_size", 13)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.08, 0.92)
	style.border_color = Color("#c8a56a")
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	b.add_theme_stylebox_override("normal", style)
	b.add_theme_stylebox_override("hover", style)
	b.add_theme_stylebox_override("pressed", style)
	b.pressed.connect(cb)
	return b

func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#f0e8d8"))
	return l

func _bar(color: Color, width: float = 180.0) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(width, 12)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
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

func _tex(path: String) -> Texture2D:
	return BrambleWorldPresentationConfig.game_tex(path)
