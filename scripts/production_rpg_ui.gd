class_name BrambleProductionRpgUi
extends CanvasLayer

const BrambleUiStyle = preload("res://scripts/bramble_ui_style.gd")

enum Screen { INVENTORY, CHARACTER, EQUIPMENT }
enum PortraitTab { BAG, CHARACTER, EQUIPMENT, DETAIL }

const RARITY_COLORS := {
	"COMMON": Color("#ded6c6"),
	"UNCOMMON": Color("#77cf76"),
	"RARE": Color("#63aefd"),
	"EPIC": Color("#c780f2"),
	"LEGENDARY": Color("#f2b54d"),
}
const EQUIP_SLOTS := [
	{"key": "head", "label": "KOPF", "pos": Vector2(0.42, 0.04)},
	{"key": "weapon", "label": "WAFFE", "pos": Vector2(0.08, 0.26)},
	{"key": "boots", "label": "STIEFEL", "pos": Vector2(0.08, 0.63)},
	{"key": "armor", "label": "RÜSTUNG", "pos": Vector2(0.76, 0.17)},
	{"key": "gloves", "label": "HÄNDE", "pos": Vector2(0.76, 0.45)},
	{"key": "accessory_1", "label": "TALISMAN", "pos": Vector2(0.76, 0.72)},
	{"key": "accessory_2", "label": "RING", "pos": Vector2(0.42, 0.78)},
]
const BASE_STATS := [
	["vitality", "VITALITÄT"],
	["strength", "STÄRKE"],
	["defense", "ABWEHR"],
	["magic", "MAGIE"],
	["resistance", "RESISTENZ"],
	["speed", "TEMPO"],
]
const DERIVED_STATS := [
	["physical_attack", "Angriff"],
	["magic_attack", "Magieangriff"],
	["physical_defense", "Verteidigung"],
	["magic_defense", "Magieabwehr"],
	["move_speed", "Bewegung"],
	["attack_speed", "Angriffstempo"],
]

var _root: Control
var _landscape: PanelContainer
var _portrait: PanelContainer
var _landscape_body: Control
var _portrait_body: Control
var _landscape_tabs: Array[Button] = []
var _portrait_tabs: Array[Button] = []
var _screen := Screen.INVENTORY
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
		orient.orientation_changed.connect(func(mode: String): _apply_layout(mode == "portrait"))

func show_inventory() -> void:
	_screen = Screen.INVENTORY
	_portrait_tab = PortraitTab.BAG
	show_panel()

func show_character() -> void:
	_screen = Screen.CHARACTER
	_portrait_tab = PortraitTab.CHARACTER
	show_panel()

func show_equipment() -> void:
	_screen = Screen.EQUIPMENT
	_portrait_tab = PortraitTab.EQUIPMENT
	show_panel()

func toggle_inventory() -> void:
	if visible and ((_portrait_mode and _portrait_tab == PortraitTab.BAG) or (not _portrait_mode and _screen == Screen.INVENTORY)):
		hide_panel()
	else:
		show_inventory()

func toggle_character() -> void:
	if visible and ((_portrait_mode and _portrait_tab == PortraitTab.CHARACTER) or (not _portrait_mode and _screen == Screen.CHARACTER)):
		hide_panel()
	else:
		show_character()

func hide_panel() -> void:
	visible = false

func show_panel() -> void:
	visible = true
	_apply_layout(_is_portrait())
	_refresh()

func select_item(item_id: String) -> void:
	_selected_item_id = item_id
	if _is_portrait():
		_portrait_tab = PortraitTab.DETAIL
	_refresh()

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0.012, 0.014, 0.018, 0.76)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)
	_landscape = _make_shell()
	_root.add_child(_landscape)
	_build_landscape_shell()
	_portrait = _make_shell()
	_root.add_child(_portrait)
	_build_portrait_shell()

func _make_shell() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", BrambleUiStyle.panel(18, 3, 0.97))
	return panel

func _build_landscape_shell() -> void:
	_landscape.custom_minimum_size = Vector2(1180, 640)
	_landscape.size = Vector2(1180, 640)
	var margin := MarginContainer.new()
	_set_margins(margin, 18)
	_landscape.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 54
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)
	var title := BrambleUiStyle.label("BRAMBLE  ·  ABENTEURERBUCH", 21, BrambleUiStyle.GOLD_BRIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	for spec in [["TASCHE", Screen.INVENTORY], ["CHARAKTER", Screen.CHARACTER], ["AUSRÜSTUNG", Screen.EQUIPMENT]]:
		var tab := _button(spec[0], func(): _set_screen(spec[1]), Vector2(142, 50))
		header.add_child(tab)
		_landscape_tabs.append(tab)
	header.add_child(_button("×", hide_panel, Vector2(52, 50)))
	_landscape_body = Control.new()
	_landscape_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_landscape_body)

func _build_portrait_shell() -> void:
	var margin := MarginContainer.new()
	_set_margins(margin, 14)
	_portrait.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 66
	column.add_child(header)
	var title := BrambleUiStyle.label("ABENTEURERBUCH", 21, BrambleUiStyle.GOLD_BRIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(_button("×", hide_panel, Vector2(56, 56)))
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	column.add_child(tabs)
	for spec in [["TASCHE", PortraitTab.BAG], ["HELD", PortraitTab.CHARACTER], ["GEAR", PortraitTab.EQUIPMENT], ["DETAIL", PortraitTab.DETAIL]]:
		var tab := _button(spec[0], func(): _set_portrait_tab(spec[1]), Vector2(0, 54))
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(tab)
		_portrait_tabs.append(tab)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_portrait_body = VBoxContainer.new()
	_portrait_body.custom_minimum_size.x = 650
	_portrait_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_portrait_body)

func _apply_layout(portrait: bool) -> void:
	_portrait_mode = portrait
	_landscape.visible = not portrait
	_portrait.visible = portrait
	var vp := get_viewport().get_visible_rect().size
	if portrait:
		_portrait.position = Vector2(18, 34)
		_portrait.size = Vector2(vp.x - 36, vp.y - 76)
	else:
		_landscape.position = Vector2((vp.x - 1180) * 0.5, (vp.y - 640) * 0.5)
		_landscape.size = Vector2(1180, 640)

func _refresh(_unused: Dictionary = {}) -> void:
	if not visible:
		return
	var portrait := _is_portrait()
	if portrait != _portrait_mode:
		_apply_layout(portrait)
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs == null:
		return
	var view: Dictionary = cs.get_character_view()
	_update_tab_states()
	if _portrait_mode:
		_clear(_portrait_body)
		_build_portrait_content(_portrait_body as VBoxContainer, view)
	else:
		_clear(_landscape_body)
		_build_landscape_content(view)

func _build_landscape_content(view: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 14)
	_landscape_body.add_child(row)
	match _screen:
		Screen.INVENTORY:
			row.add_child(_character_card(view, Vector2(300, 548)))
			row.add_child(_inventory_card(view, Vector2(500, 548), 5, 74))
			row.add_child(_detail_card(view, Vector2(300, 548)))
		Screen.CHARACTER:
			row.add_child(_character_card(view, Vector2(360, 548)))
			row.add_child(_stats_card(view, Vector2(430, 548)))
			row.add_child(_progression_card(view, Vector2(340, 548)))
		Screen.EQUIPMENT:
			row.add_child(_equipment_card(view, Vector2(420, 548)))
			row.add_child(_equipped_list_card(view, Vector2(360, 548)))
			row.add_child(_detail_card(view, Vector2(350, 548)))

func _build_portrait_content(host: VBoxContainer, view: Dictionary) -> void:
	host.add_theme_constant_override("separation", 12)
	match _portrait_tab:
		PortraitTab.BAG:
			host.add_child(_identity_strip(view))
			host.add_child(_inventory_card(view, Vector2(650, 800), 5, 104))
			if _selected_item_id != "":
				host.add_child(_selected_summary(view))
		PortraitTab.CHARACTER:
			host.add_child(_character_card(view, Vector2(650, 470)))
			host.add_child(_stats_card(view, Vector2(650, 520)))
		PortraitTab.EQUIPMENT:
			host.add_child(_equipment_card(view, Vector2(650, 650)))
			host.add_child(_equipped_list_card(view, Vector2(650, 370)))
		PortraitTab.DETAIL:
			host.add_child(_detail_card(view, Vector2(650, 890)))

func _character_card(view: Dictionary, size: Vector2) -> PanelContainer:
	var panel := _card(size)
	var col := _card_column(panel, 14)
	var identity := BrambleUiStyle.label("%s  ·  LEVEL %d" % [view.get("display_name", "Hüter"), view.get("level", 1)], 20, BrambleUiStyle.GOLD_BRIGHT)
	identity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(identity)
	var portrait_frame := PanelContainer.new()
	portrait_frame.custom_minimum_size.y = maxf(150, size.y * 0.43)
	portrait_frame.add_theme_stylebox_override("panel", BrambleUiStyle.inset(14))
	col.add_child(portrait_frame)
	var portrait := TextureRect.new()
	portrait.texture = BrambleUiStyle.texture("characters/base/male/directions/front.png")
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 20
	portrait.offset_top = 8
	portrait.offset_right = -20
	portrait.offset_bottom = -8
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_frame.add_child(portrait)
	col.add_child(_resource_row("HP", int(view.get("hp", 0)), int(view.get("max_hp", 1)), BrambleUiStyle.HP))
	col.add_child(_resource_row("MP", int(view.get("mp", 0)), int(view.get("max_mp", 1)), BrambleUiStyle.MP))
	col.add_child(_resource_row("XP", int(view.get("xp", 0)), int(view.get("xp_to_next_level", 1)), BrambleUiStyle.XP))
	var footer := BrambleUiStyle.label("%d Gold  ·  %d Statpunkte" % [view.get("gold", 0), view.get("available_stat_points", 0)], 15, BrambleUiStyle.MUTED)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(footer)
	return panel

func _identity_strip(view: Dictionary) -> PanelContainer:
	var panel := _card(Vector2(650, 112))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var portrait := TextureRect.new()
	portrait.texture = BrambleUiStyle.texture("characters/base/male/directions/front.png")
	portrait.custom_minimum_size = Vector2(80, 90)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(portrait)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	col.add_child(BrambleUiStyle.label("%s  ·  Lv %d" % [view.get("display_name", "Hüter"), view.get("level", 1)], 19, BrambleUiStyle.GOLD_BRIGHT))
	col.add_child(_resource_row("HP", int(view.get("hp", 0)), int(view.get("max_hp", 1)), BrambleUiStyle.HP))
	col.add_child(_resource_row("MP", int(view.get("mp", 0)), int(view.get("max_mp", 1)), BrambleUiStyle.MP))
	return panel

func _inventory_card(view: Dictionary, size: Vector2, columns: int, slot_size: int) -> PanelContainer:
	var panel := _card(size)
	var col := _card_column(panel, 10)
	var title_row := HBoxContainer.new()
	col.add_child(title_row)
	var title := BrambleUiStyle.label("TASCHE", 20, BrambleUiStyle.GOLD_BRIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	title_row.add_child(BrambleUiStyle.label("%d / %d" % [view.get("inventory", []).size(), view.get("inventory_capacity", 28)], 15, BrambleUiStyle.MUTED))
	var categories := HBoxContainer.new()
	categories.add_theme_constant_override("separation", 5)
	col.add_child(categories)
	for spec in [["ALLE", "ALL"], ["GEAR", "GEAR"], ["TRANK", "CONSUMABLE"], ["MATERIAL", "MATERIAL"]]:
		var b := _button(spec[0], func(): _set_category(spec[1]), Vector2(0, 48))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		BrambleUiStyle.apply_button(b, _category == spec[1])
		categories.add_child(b)
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	col.add_child(grid)
	var entries: Array = []
	for entry in view.get("inventory", []):
		if _category_match(entry):
			entries.append(entry)
	for entry in entries:
		grid.add_child(_inventory_slot(entry, slot_size))
	var target_slots := columns * (5 if size.y > 650 else 4)
	for _i in range(maxi(0, target_slots - entries.size())):
		grid.add_child(_empty_slot(slot_size))
	return panel

func _inventory_slot(entry: Dictionary, slot_size: int) -> PanelContainer:
	var item_id := String(entry.get("item_id", ""))
	var item := _item_data(item_id)
	var rarity := String(item.get("rarity", entry.get("rarity", "COMMON")))
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(slot_size, slot_size)
	var selected := item_id == _selected_item_id
	var style := BrambleUiStyle.inset(10, selected)
	style.border_color = RARITY_COLORS.get(rarity, BrambleUiStyle.GOLD)
	style.set_border_width_all(4 if selected else 2)
	slot.add_theme_stylebox_override("panel", style)
	var icon := TextureRect.new()
	icon.texture = _item_icon(item)
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 8
	icon.offset_top = 8
	icon.offset_right = -8
	icon.offset_bottom = -8
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	var qty := int(entry.get("quantity", 1))
	if qty > 1:
		var badge := BrambleUiStyle.label("%d" % qty, 15, Color.WHITE)
		badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		badge.offset_left = -38
		badge.offset_top = -27
		badge.offset_right = -7
		badge.offset_bottom = -5
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(badge)
	var hit := Button.new()
	hit.flat = true
	hit.set_anchors_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = String(item.get("display_name", item_id))
	hit.pressed.connect(func(): select_item(item_id))
	slot.add_child(hit)
	return slot

func _empty_slot(slot_size: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(slot_size, slot_size)
	slot.add_theme_stylebox_override("panel", BrambleUiStyle.inset(10))
	return slot

func _equipment_card(view: Dictionary, size: Vector2) -> PanelContainer:
	var panel := _card(size)
	var col := _card_column(panel, 8)
	var title := BrambleUiStyle.label("AUSRÜSTUNG", 20, BrambleUiStyle.GOLD_BRIGHT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var board_size := minf(size.x - 28, size.y - 72)
	var board := Control.new()
	board.custom_minimum_size = Vector2(board_size, board_size)
	board.size = Vector2(board_size, board_size)
	board.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(board)
	var bg := TextureRect.new()
	bg.texture = BrambleUiStyle.texture("ui/equipment/equipment_panel.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.modulate = Color(1, 1, 1, 0.58)
	board.add_child(bg)
	board.clip_contents = true
	var avatar := Sprite2D.new()
	avatar.texture = BrambleUiStyle.texture("characters/base/male/directions/front.png")
	avatar.position = Vector2(board_size * 0.50, board_size * 0.54)
	avatar.scale = Vector2.ONE * (board_size / 1100.0)
	board.add_child(avatar)
	var equipment: Dictionary = view.get("equipment", {})
	for spec in EQUIP_SLOTS:
		var slot_size := board_size * 0.16
		var slot := PanelContainer.new()
		slot.position = Vector2(spec.pos) * board_size
		slot.size = Vector2(slot_size, slot_size)
		slot.add_theme_stylebox_override("panel", BrambleUiStyle.inset(9, false))
		board.add_child(slot)
		var item_id := String(equipment.get(spec.key, ""))
		var item := _item_data(item_id)
		if item_id != "":
			var icon := TextureRect.new()
			icon.texture = _item_icon(item)
			icon.set_anchors_preset(Control.PRESET_FULL_RECT)
			icon.offset_left = 5
			icon.offset_top = 5
			icon.offset_right = -5
			icon.offset_bottom = -5
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			slot.add_child(icon)
		var label := BrambleUiStyle.label(spec.label, 10, BrambleUiStyle.MUTED)
		label.position = Vector2(0, slot_size - 18)
		label.size = Vector2(slot_size, 18)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.add_child(label)
	return panel

func _stats_card(view: Dictionary, size: Vector2) -> PanelContainer:
	var panel := _card(size)
	var col := _card_column(panel, 9)
	col.add_child(BrambleUiStyle.label("PRIMÄRWERTE", 20, BrambleUiStyle.GOLD_BRIGHT))
	var base: Dictionary = view.get("base_stats", {})
	var points := int(view.get("available_stat_points", 0))
	col.add_child(BrambleUiStyle.label("Verfügbare Punkte: %d" % points, 15, BrambleUiStyle.MUTED))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	col.add_child(grid)
	for spec in BASE_STATS:
		var row := PanelContainer.new()
		row.custom_minimum_size = Vector2((size.x - 48) * 0.5, 58)
		row.add_theme_stylebox_override("panel", BrambleUiStyle.inset(9))
		grid.add_child(row)
		var h := HBoxContainer.new()
		row.add_child(h)
		var label := BrambleUiStyle.label(spec[1], 14)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(label)
		h.add_child(BrambleUiStyle.label(str(int(base.get(spec[0], 0))), 19, BrambleUiStyle.GOLD_BRIGHT))
		if points > 0:
			h.add_child(_button("+", func(): _allocate(spec[0]), Vector2(48, 48)))
	col.add_child(_separator())
	col.add_child(BrambleUiStyle.label("KAMPFWERTE", 18, BrambleUiStyle.GOLD_BRIGHT))
	var derived: Dictionary = view.get("derived_stats", {})
	for spec in DERIVED_STATS:
		var line := HBoxContainer.new()
		var key := BrambleUiStyle.label(spec[1], 14, BrambleUiStyle.MUTED)
		key.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(key)
		line.add_child(BrambleUiStyle.label(str(derived.get(spec[0], 0)), 15))
		col.add_child(line)
	return panel

func _progression_card(view: Dictionary, size: Vector2) -> PanelContainer:
	var panel := _card(size)
	var col := _card_column(panel, 12)
	col.add_child(BrambleUiStyle.label("FORTSCHRITT", 20, BrambleUiStyle.GOLD_BRIGHT))
	col.add_child(BrambleUiStyle.label("Level %d" % view.get("level", 1), 30))
	col.add_child(_resource_row("ERFAHRUNG", int(view.get("xp", 0)), int(view.get("xp_to_next_level", 1)), BrambleUiStyle.XP))
	col.add_child(_separator())
	col.add_child(BrambleUiStyle.label("AKTIVE FÄHIGKEITEN", 17, BrambleUiStyle.GOLD_BRIGHT))
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	for i in range(3):
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 62
		var skill_id := ""
		var skillbar: Array = view.get("skillbar", [])
		if i < skillbar.size():
			skill_id = String(skillbar[i])
		var skill := db.skill_by_id("adventurer", skill_id) if db and skill_id != "" else {}
		var icon := TextureRect.new()
		icon.texture = _texture(String(skill.get("icon", "ui/skills/skill_locked.png")))
		icon.custom_minimum_size = Vector2(56, 56)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		var text := String(skill.get("display_name", "Gesperrter Slot"))
		row.add_child(BrambleUiStyle.label(text, 15, BrambleUiStyle.INK if not skill.is_empty() else BrambleUiStyle.MUTED))
		col.add_child(row)
	col.add_child(_separator())
	col.add_child(BrambleUiStyle.label("%d Gold" % view.get("gold", 0), 18, BrambleUiStyle.GOLD_BRIGHT))
	return panel

func _equipped_list_card(view: Dictionary, size: Vector2) -> PanelContainer:
	var panel := _card(size)
	var col := _card_column(panel, 7)
	col.add_child(BrambleUiStyle.label("AUSGERÜSTET", 20, BrambleUiStyle.GOLD_BRIGHT))
	var equipment: Dictionary = view.get("equipment", {})
	for spec in EQUIP_SLOTS:
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 55
		var item_id := String(equipment.get(spec.key, ""))
		var item := _item_data(item_id)
		var icon := TextureRect.new()
		icon.texture = _item_icon(item) if item_id != "" else null
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		var text := String(item.get("display_name", "Leer"))
		var label := BrambleUiStyle.label("%s\n%s" % [spec.label, text], 13, BrambleUiStyle.INK if item_id != "" else BrambleUiStyle.MUTED)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		col.add_child(row)
	return panel

func _detail_card(view: Dictionary, size: Vector2) -> PanelContainer:
	var panel := _card(size)
	var col := _card_column(panel, 10)
	col.add_child(BrambleUiStyle.label("ITEM-DETAIL", 20, BrambleUiStyle.GOLD_BRIGHT))
	if _selected_item_id == "":
		var hint := BrambleUiStyle.label("Wähle ein Item aus deiner Tasche.", 16, BrambleUiStyle.MUTED)
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		col.add_child(hint)
		return panel
	var item := _item_data(_selected_item_id)
	var rarity := String(item.get("rarity", "COMMON"))
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	col.add_child(header)
	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(92, 92)
	var icon_style := BrambleUiStyle.inset(12, true)
	icon_style.border_color = RARITY_COLORS.get(rarity, BrambleUiStyle.GOLD)
	icon_frame.add_theme_stylebox_override("panel", icon_style)
	header.add_child(icon_frame)
	var icon := TextureRect.new()
	icon.texture = _item_icon(item)
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 8
	icon.offset_top = 8
	icon.offset_right = -8
	icon.offset_bottom = -8
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_frame.add_child(icon)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(names)
	names.add_child(BrambleUiStyle.label(String(item.get("display_name", _selected_item_id)), 19, RARITY_COLORS.get(rarity, BrambleUiStyle.INK)))
	names.add_child(BrambleUiStyle.label("%s  ·  Level %d" % [rarity, item.get("required_level", 1)], 13, BrambleUiStyle.MUTED))
	var desc := BrambleUiStyle.label(String(item.get("description", "")), 15)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(desc)
	col.add_child(_separator())
	var mods: Dictionary = item.get("stat_modifiers", {})
	if not mods.is_empty():
		col.add_child(BrambleUiStyle.label("WERTE", 15, BrambleUiStyle.GOLD_BRIGHT))
		for key in mods.keys():
			col.add_child(BrambleUiStyle.label("%s  +%s" % [_stat_name(key), mods[key]], 15, BrambleUiStyle.POSITIVE))
	if String(item.get("category", "")) == "EQUIPMENT":
		_add_comparison(col, item, view)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if String(item.get("category", "")) == "EQUIPMENT":
		col.add_child(_button("AUSRÜSTEN", func():
			if cs and cs.equip_from_inventory(_selected_item_id):
				_refresh()
		, Vector2(0, 56)))
	elif String(item.get("category", "")) == "CONSUMABLE":
		col.add_child(_button("BENUTZEN", func():
			if cs:
				cs.use_consumable(_selected_item_id)
		, Vector2(0, 56)))
	return panel

func _selected_summary(view: Dictionary) -> PanelContainer:
	var card := _detail_card(view, Vector2(650, 260))
	return card

func _add_comparison(col: VBoxContainer, selected: Dictionary, view: Dictionary) -> void:
	var slot := String(selected.get("allowed_slot", ""))
	var equipped_id := String(view.get("equipment", {}).get(slot, ""))
	if equipped_id == _selected_item_id:
		col.add_child(BrambleUiStyle.label("✓ Aktuell ausgerüstet", 15, BrambleUiStyle.POSITIVE))
		return
	if equipped_id == "":
		return
	var current := _item_data(equipped_id)
	col.add_child(_separator())
	col.add_child(BrambleUiStyle.label("VERGLEICH MIT %s" % String(current.get("display_name", "Ausrüstung")).to_upper(), 14, BrambleUiStyle.GOLD_BRIGHT))
	var current_mods: Dictionary = current.get("stat_modifiers", {})
	var selected_mods: Dictionary = selected.get("stat_modifiers", {})
	var keys := {}
	for key in current_mods:
		keys[key] = true
	for key in selected_mods:
		keys[key] = true
	for key in keys:
		var delta := int(selected_mods.get(key, 0)) - int(current_mods.get(key, 0))
		var color := BrambleUiStyle.POSITIVE if delta >= 0 else BrambleUiStyle.NEGATIVE
		col.add_child(BrambleUiStyle.label("%s  %s%d" % [_stat_name(key), "+" if delta >= 0 else "", delta], 14, color))

func _resource_row(name: String, value: int, maximum: int, color: Color) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 24
	var label := BrambleUiStyle.label(name, 12, BrambleUiStyle.MUTED)
	label.custom_minimum_size.x = 34
	row.add_child(label)
	var bar := BrambleUiStyle.progress(color, 14)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.max_value = maxi(1, maximum)
	bar.value = value
	row.add_child(bar)
	var amount := BrambleUiStyle.label("%d/%d" % [value, maximum], 12)
	amount.custom_minimum_size.x = 68
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(amount)
	return row

func _card(size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = size
	panel.add_theme_stylebox_override("panel", BrambleUiStyle.panel(14, 2, 0.93))
	return panel

func _card_column(panel: PanelContainer, separation: int) -> VBoxContainer:
	var margin := MarginContainer.new()
	_set_margins(margin, 14)
	panel.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", separation)
	margin.add_child(col)
	return col

func _button(text: String, callback: Callable, minimum := Vector2(96, 50)) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = minimum
	BrambleUiStyle.apply_button(button)
	button.pressed.connect(callback)
	return button

func _separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	return sep

func _set_margins(margin: MarginContainer, amount: int) -> void:
	margin.add_theme_constant_override("margin_left", amount)
	margin.add_theme_constant_override("margin_top", amount)
	margin.add_theme_constant_override("margin_right", amount)
	margin.add_theme_constant_override("margin_bottom", amount)

func _set_screen(value: Screen) -> void:
	_screen = value
	_refresh()

func _set_portrait_tab(value: PortraitTab) -> void:
	_portrait_tab = value
	_refresh()

func _set_category(value: String) -> void:
	_category = value
	_refresh()

func _update_tab_states() -> void:
	for i in range(_landscape_tabs.size()):
		BrambleUiStyle.apply_button(_landscape_tabs[i], i == _screen)
	for i in range(_portrait_tabs.size()):
		BrambleUiStyle.apply_button(_portrait_tabs[i], i == _portrait_tab)

func _allocate(stat: String) -> void:
	var cs = get_tree().get_first_node_in_group("character_state_service")
	if cs and cs.allocate_stat(stat):
		_refresh()

func _category_match(entry: Dictionary) -> bool:
	if _category == "ALL":
		return true
	var category := String(entry.get("category", "MISC"))
	if _category == "GEAR":
		return category == "EQUIPMENT"
	return category == _category

func _item_data(item_id: String) -> Dictionary:
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	return db.item_data(item_id) if db and item_id != "" else {}

func _item_icon(item: Dictionary) -> Texture2D:
	var path := String(item.get("icon", ""))
	if path == "":
		return BrambleUiStyle.texture("items/misc/supply_pouch.png")
	if String(item.get("item_id", "")) == "trail_gloves":
		var atlas := AtlasTexture.new()
		atlas.atlas = _texture(path)
		atlas.region = Rect2(330, 430, 125, 175)
		return atlas
	return _texture(path)

func _texture(path: String) -> Texture2D:
	if path.begins_with("res://"):
		return load(path) if ResourceLoader.exists(path) else null
	return BrambleUiStyle.texture(path)

func _stat_name(key: String) -> String:
	var names := {
		"strength": "Stärke",
		"defense": "Abwehr",
		"vitality": "Vitalität",
		"magic": "Magie",
		"resistance": "Resistenz",
		"speed": "Tempo",
		"physical_attack": "Angriff",
		"max_mp": "Max. MP",
	}
	return String(names.get(key, key.capitalize()))

func _is_portrait() -> bool:
	var orient := get_tree().get_first_node_in_group("orientation_service") as BrambleOrientationService
	if orient:
		return orient.is_portrait()
	var size := get_viewport().get_visible_rect().size
	return size.y > size.x

func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
