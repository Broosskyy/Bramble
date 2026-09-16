class_name BrambleProductionEquipmentVisual
extends Node

var _weapon_sprite: Sprite2D

func _ready() -> void:
	add_to_group("production_equipment_visual")
	call_deferred("_bind_player")

func _bind_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	_weapon_sprite = Sprite2D.new()
	_weapon_sprite.name = "EquippedWeaponOverlay"
	_weapon_sprite.position = Vector2(18, -72)
	_weapon_sprite.scale = Vector2(0.22, 0.22)
	_weapon_sprite.visible = false
	player.add_child(_weapon_sprite)
	var equip := get_tree().get_first_node_in_group("equipment_service") as BrambleEquipmentService
	if equip:
		equip.equipment_changed.connect(func(_peer, _eq): refresh_from_character())
	refresh_from_character()

func refresh_from_character() -> void:
	if _weapon_sprite == null:
		return
	var cs = get_tree().get_first_node_in_group("character_state_service")
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	if cs == null or db == null:
		return
	var view: Dictionary = cs.get_character_view()
	var weapon_id := String(view.get("equipment", {}).get("weapon", ""))
	if weapon_id == "":
		_weapon_sprite.visible = false
		return
	var item := db.item_data(weapon_id)
	var visual: Dictionary = item.get("visual_reference", {})
	var weapon_key := String(visual.get("weapon", "sword"))
	var path := "res://assets/equipment/weapons/%s.png" % weapon_key
	if ResourceLoader.exists(path):
		_weapon_sprite.texture = load(path)
		_weapon_sprite.visible = true
	else:
		var fallback := BrambleWorldPresentationConfig.game_tex("characters/equipment/weapons/melee/short_sword.png")
		_weapon_sprite.texture = fallback
		_weapon_sprite.visible = fallback != null
