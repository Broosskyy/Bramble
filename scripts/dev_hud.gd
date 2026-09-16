class_name BrambleDevHud
extends CanvasLayer

@onready var gallery: Control = $AssetGallery
@onready var grid: GridContainer = $AssetGallery/Panel/Margin/VBox/Scroll/Grid
@onready var page_label: Label = $AssetGallery/Panel/Margin/VBox/Nav/Page
@onready var dialogue: PanelContainer = $Dialogue
@onready var dialogue_title: Label = $Dialogue/Margin/VBox/Title
@onready var dialogue_text: Label = $Dialogue/Margin/VBox/Text
@onready var toast: Label = $Toast

var inventory: Dictionary = {}
var page := 0
var toast_time := 0.0
const PAGE_SIZE := 24

func _ready() -> void:
	add_to_group("hud")
	$TopBar/Gallery.pressed.connect(_toggle_gallery)
	$AssetGallery/Panel/Margin/VBox/Nav/Prev.pressed.connect(_prev)
	$AssetGallery/Panel/Margin/VBox/Nav/Next.pressed.connect(_next)
	$AssetGallery/Panel/Margin/VBox/Close.pressed.connect(_toggle_gallery)
	$Dialogue/Margin/VBox/Close.pressed.connect(func(): dialogue.visible = false)

	_bind_touch($Touch/Left, "move_left")
	_bind_touch($Touch/Right, "move_right")
	_bind_touch($Touch/Up, "move_up")
	_bind_touch($Touch/Down, "move_down")
	$Touch/Attack.button_down.connect(func(): Input.action_press("basic_attack"))
	$Touch/Attack.button_up.connect(func(): Input.action_release("basic_attack"))
	$Touch/Interact.button_down.connect(func(): Input.action_press("interact"))
	$Touch/Interact.button_up.connect(func(): Input.action_release("interact"))
	$Touch/Potion.button_down.connect(func(): Input.action_press("use_potion"))
	$Touch/Potion.button_up.connect(func(): Input.action_release("use_potion"))

	var f := FileAccess.open("res://data/all_workchat_asset_inventory.json", FileAccess.READ)
	if f:
		var parsed: Variant = JSON.parse_string(f.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			inventory = parsed
	_render_page()

	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state:
		state.quest_changed.connect(_on_quest_changed)
		state.player_stats_changed.connect(_on_stats_changed)
		state.toast_requested.connect(show_toast)
		state._emit_all()

func _process(delta: float) -> void:
	if toast_time > 0.0:
		toast_time -= delta
		if toast_time <= 0.0:
			toast.visible = false

func _bind_touch(button: BaseButton, action: String) -> void:
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))

func _on_quest_changed(title: String, text: String) -> void:
	$Quest/VBox/Title.text = title
	$Quest/VBox/Text.text = text

func _on_stats_changed(hp: int, max_hp: int, level: int, xp: int, gold: int) -> void:
	$Stats/VBox/HP.value = hp
	$Stats/VBox/HP.max_value = max_hp
	$Stats/VBox/Info.text = "LV %d · XP %d/%d · %d G" % [level, xp, level*100, gold]

func show_dialogue(title: String, text: String) -> void:
	dialogue_title.text = title
	dialogue_text.text = text
	dialogue.visible = true

func show_toast(text: String) -> void:
	toast.text = text
	toast.visible = true
	toast_time = 2.4

func _toggle_gallery() -> void:
	gallery.visible = not gallery.visible
	get_tree().paused = gallery.visible

func _prev() -> void:
	page = maxi(0, page - 1)
	_render_page()

func _next() -> void:
	var total := int(inventory.get("assets", []).size())
	var max_page := maxi(0, int(ceil(float(total) / PAGE_SIZE)) - 1)
	page = mini(max_page, page + 1)
	_render_page()

func _render_page() -> void:
	if grid == null:
		return
	for child in grid.get_children():
		child.queue_free()
	var assets: Array = inventory.get("assets", [])
	var start := page * PAGE_SIZE
	var end := mini(start + PAGE_SIZE, assets.size())
	for i in range(start, end):
		var e: Dictionary = assets[i]
		var cell := VBoxContainer.new()
		cell.custom_minimum_size = Vector2(150,150)
		var texrect := TextureRect.new()
		texrect.custom_minimum_size = Vector2(140,110)
		texrect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texrect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var tex := load("res://" + String(e.get("file",""))) as Texture2D
		if tex:
			texrect.texture = tex
		cell.add_child(texrect)
		var label := Label.new()
		label.text = String(e.get("original_name","asset")).left(22)
		label.add_theme_font_size_override("font_size",11)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(label)
		grid.add_child(cell)
	var pages := maxi(1,int(ceil(float(assets.size())/PAGE_SIZE)))
	page_label.text = "Assets %d–%d / %d · Seite %d/%d" % [start+1 if assets.size() else 0,end,assets.size(),page+1,pages]
