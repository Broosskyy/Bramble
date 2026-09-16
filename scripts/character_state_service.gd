class_name BrambleCharacterStateService
extends Node

signal character_changed(view: Dictionary)
signal level_up(new_level: int, rewards: Dictionary)
signal inventory_changed(inventory: Array)
signal equipment_changed(equipment: Dictionary)
signal skillbar_changed(skillbar: Array)

const LOCAL_ACCOUNT := "offline_local"
const INVENTORY_CAPACITY := 28
const M04_TO_AUTHORITY_SLOT := {
	"weapon": "weapon",
	"armor": "chest",
	"gloves": "hands",
	"boots": "feet",
	"head": "head",
	"accessory_1": "accessory",
	"accessory_2": "offhand",
}
const AUTHORITY_TO_M04_SLOT := {
	"weapon": "weapon",
	"chest": "armor",
	"hands": "gloves",
	"feet": "boots",
	"head": "head",
	"accessory": "accessory_1",
	"offhand": "accessory_2",
}

var _loaded := false

func _ready() -> void:
	add_to_group("character_state_service")
	level_up.connect(_on_level_up)
	call_deferred("_bootstrap_local_character")

func _on_level_up(new_level: int, _rewards: Dictionary) -> void:
	var gs := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if gs:
		gs.toast_requested.emit("LEVEL UP · Level %d" % new_level)

func local_peer_id() -> int:
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	if net and net.mode != "offline":
		return multiplayer.get_unique_id()
	return 1

func _bootstrap_local_character() -> void:
	if _loaded:
		return
	var peer_id := local_peer_id()
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	var chars := get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
	if pa == null or chars == null:
		return
	var existing := chars.resolve(LOCAL_ACCOUNT, {}, _default_seed())
	if existing.is_empty():
		existing = chars.create_character(LOCAL_ACCOUNT, {"name": "Hüter", "class_id": "adventurer"}, _default_seed())
	var state := pa.ensure_peer(peer_id, existing)
	_merge_character_fields(state, existing)
	state["account_id"] = LOCAL_ACCOUNT
	state["display_name"] = String(state.get("name", "Hüter"))
	if state.get("inventory", []).is_empty():
		_seed_starter_items(peer_id)
	_recalculate(peer_id)
	_sync_game_state()
	_loaded = true
	character_changed.emit(get_character_view())

func _default_seed() -> Dictionary:
	var cfg := _progression_cfg()
	var base: Dictionary = cfg.get("base_stats", {}).duplicate(true)
	return {
		"account_id": LOCAL_ACCOUNT,
		"name": "Hüter",
		"display_name": "Hüter",
		"class_id": "adventurer",
		"level": 1,
		"xp": 0,
		"gold": 0,
		"base_stats": base,
		"available_stat_points": 0,
		"available_skill_points": 0,
		"inventory_capacity": INVENTORY_CAPACITY,
		"known_skills": ["cut", "wild_slash"],
		"unlocked_skills": ["cut"],
		"skillbar": ["cut", "wild_slash", ""],
		"mp": 40,
		"equipment": {},
		"inventory": [],
	}

func _seed_starter_items(peer_id: int) -> void:
	var inv := get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
	if inv == null:
		return
	inv.add_item(peer_id, "rusty_blade", 1)
	inv.add_item(peer_id, "leather_vest", 1)
	inv.add_item(peer_id, "trail_gloves", 1)
	inv.add_item(peer_id, "trail_boots", 1)
	inv.add_item(peer_id, "potion", 3)
	inv.add_item(peer_id, "forest_blade", 1)

func get_character_view() -> Dictionary:
	var peer_id := local_peer_id()
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if pa == null:
		return {}
	var state := pa.ensure_peer(peer_id)
	var pipeline = get_tree().get_first_node_in_group("stat_pipeline_service")
	var calc: Dictionary = pipeline.calculate(state) if pipeline else {}
	var xp_next: int = pipeline.xp_to_next_level(int(state.get("level", 1))) if pipeline else 100
	return {
		"character_id": state.get("character_id", ""),
		"display_name": state.get("display_name", state.get("name", "Adventurer")),
		"level": int(state.get("level", 1)),
		"xp": int(state.get("xp", 0)),
		"xp_to_next_level": xp_next,
		"gold": int(state.get("gold", 0)),
		"hp": int(state.get("hp", 100)),
		"max_hp": int(state.get("max_hp", 100)),
		"mp": int(state.get("mp", 40)),
		"max_mp": int(state.get("max_mp", 40)),
		"available_stat_points": int(state.get("available_stat_points", 0)),
		"available_skill_points": int(state.get("available_skill_points", 0)),
		"base_stats": state.get("base_stats", {}).duplicate(true),
		"final_stats": calc.get("final", {}),
		"derived_stats": calc.get("derived", state.get("derived_stats", {})),
		"inventory": _inventory_view(state),
		"equipment": equipment_view(state),
		"known_skills": state.get("known_skills", []).duplicate(true),
		"unlocked_skills": state.get("unlocked_skills", []).duplicate(true),
		"skillbar": state.get("skillbar", []).duplicate(true),
		"inventory_capacity": int(state.get("inventory_capacity", INVENTORY_CAPACITY)),
	}

func equipment_view(state: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for auth_slot in state.get("equipment", {}).keys():
		var m04_slot := String(AUTHORITY_TO_M04_SLOT.get(String(auth_slot), auth_slot))
		out[m04_slot] = _equipped_item_id(state["equipment"][auth_slot])
	return out

func grant_xp(amount: int) -> void:
	var peer_id := local_peer_id()
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	var pipeline = get_tree().get_first_node_in_group("stat_pipeline_service")
	if pa == null or pipeline == null:
		return
	var cfg := _progression_cfg()
	var mult := float(cfg.get("qa_xp_multiplier", 1.0))
	var state := pa.ensure_peer(peer_id)
	state["xp"] = int(state.get("xp", 0)) + maxi(0, int(round(float(amount) * mult)))
	var rewards_cfg: Dictionary = cfg.get("level_rewards", {})
	var max_level := int(cfg.get("max_level", 30))
	while int(state["level"]) < max_level:
		var needed: int = pipeline.xp_to_next_level(int(state["level"]))
		if int(state["xp"]) < needed:
			break
		state["xp"] = int(state["xp"]) - needed
		state["level"] = int(state["level"]) + 1
		state["available_stat_points"] = int(state.get("available_stat_points", 0)) + int(rewards_cfg.get("stat_points", 2))
		state["available_skill_points"] = int(state.get("available_skill_points", 0)) + int(rewards_cfg.get("skill_points", 1))
		_unlock_skills_for_level(state)
		level_up.emit(int(state["level"]), rewards_cfg.duplicate(true))
	_recalculate(peer_id)
	_persist(peer_id)
	_sync_game_state()
	character_changed.emit(get_character_view())

func allocate_stat(stat_name: String) -> bool:
	if stat_name not in ["vitality", "strength", "defense", "magic", "resistance", "speed"]:
		return false
	var peer_id := local_peer_id()
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if pa == null:
		return false
	var state := pa.ensure_peer(peer_id)
	if int(state.get("available_stat_points", 0)) <= 0:
		return false
	var base_stats: Dictionary = state.get("base_stats", {})
	base_stats[stat_name] = int(base_stats.get(stat_name, 0)) + 1
	state["base_stats"] = base_stats
	state["available_stat_points"] = int(state["available_stat_points"]) - 1
	_recalculate(peer_id)
	_persist(peer_id)
	_sync_game_state()
	character_changed.emit(get_character_view())
	return true

func add_loot(item_id: String, qty: int = 1, gold: int = 0) -> bool:
	var peer_id := local_peer_id()
	var inv := get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if inv == null or pa == null:
		return false
	if item_id != "" and not can_add_item(item_id, qty):
		return false
	if item_id != "" and not inv.add_item(peer_id, item_id, qty):
		return false
	if gold > 0:
		var state := pa.ensure_peer(peer_id)
		state["gold"] = int(state.get("gold", 0)) + gold
		_persist(peer_id)
	_sync_game_state()
	character_changed.emit(get_character_view())
	inventory_changed.emit(get_character_view().get("inventory", []))
	return true

func can_add_item(item_id: String, qty: int = 1) -> bool:
	var view := get_character_view()
	var used := _inventory_slots_used(view.get("inventory", []))
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	var item := db.item_data(item_id) if db else {}
	if item.is_empty():
		return false
	if bool(item.get("stackable", false)):
		return used <= int(view.get("inventory_capacity", INVENTORY_CAPACITY))
	return used + qty <= int(view.get("inventory_capacity", INVENTORY_CAPACITY))

func equip_from_inventory(item_id: String) -> Dictionary:
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	var item := db.item_data(item_id) if db else {}
	if item.is_empty():
		return {"ok": false, "reason": "unknown_item"}
	var slot := String(item.get("allowed_slot", ""))
	if slot == "":
		return {"ok": false, "reason": "not_equipment"}
	return equip_item(item_id, slot)

func equip_item(item_id: String, m04_slot: String) -> Dictionary:
	var peer_id := local_peer_id()
	var inv := get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
	var equip := get_tree().get_first_node_in_group("equipment_service") as BrambleEquipmentService
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	if inv == null or equip == null or db == null:
		return {"ok": false, "reason": "service_unavailable"}
	var item := db.item_data(item_id)
	if item.is_empty():
		return {"ok": false, "reason": "unknown_item"}
	if int(get_character_view().get("level", 1)) < int(item.get("required_level", 1)):
		return {"ok": false, "reason": "level_too_low"}
	if not inv.owns(peer_id, item_id, 1):
		return {"ok": false, "reason": "not_owned"}
	var auth_slot := String(M04_TO_AUTHORITY_SLOT.get(m04_slot, m04_slot))
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	var state := pa.ensure_peer(peer_id)
	var eq: Dictionary = state.get("equipment", {})
	var previous := _equipped_item_id(eq.get(auth_slot, ""))
	if not inv.remove_item(peer_id, item_id, 1):
		return {"ok": false, "reason": "remove_failed"}
	if previous != "":
		inv.add_item(peer_id, previous, 1)
	if not equip.equip(peer_id, auth_slot, item_id):
		inv.add_item(peer_id, item_id, 1)
		if previous != "":
			inv.remove_item(peer_id, previous, 1)
		return {"ok": false, "reason": "equip_rejected"}
	_apply_equipment_visuals()
	_recalculate(peer_id)
	_sync_game_state()
	character_changed.emit(get_character_view())
	equipment_changed.emit(get_character_view().get("equipment", {}))
	return {"ok": true}

func unequip_slot(m04_slot: String) -> Dictionary:
	var peer_id := local_peer_id()
	var auth_slot := String(M04_TO_AUTHORITY_SLOT.get(m04_slot, m04_slot))
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	var equip := get_tree().get_first_node_in_group("equipment_service") as BrambleEquipmentService
	var inv := get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
	if pa == null or equip == null or inv == null:
		return {"ok": false, "reason": "service_unavailable"}
	var state := pa.ensure_peer(peer_id)
	var current := _equipped_item_id(state.get("equipment", {}).get(auth_slot, ""))
	if current == "":
		return {"ok": false, "reason": "empty_slot"}
	if not can_add_item(current, 1):
		return {"ok": false, "reason": "inventory_full"}
	equip.unequip(peer_id, auth_slot)
	inv.add_item(peer_id, current, 1)
	_apply_equipment_visuals()
	_recalculate(peer_id)
	_sync_game_state()
	character_changed.emit(get_character_view())
	return {"ok": true}

func use_consumable(item_id: String) -> bool:
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	var item := db.item_data(item_id) if db else {}
	if item.is_empty() or String(item.get("category", "")) != "CONSUMABLE":
		return false
	var peer_id := local_peer_id()
	var inv := get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if inv == null or pa == null or not inv.owns(peer_id, item_id, 1):
		return false
	if not inv.remove_item(peer_id, item_id, 1):
		return false
	var state := pa.ensure_peer(peer_id)
	state["hp"] = mini(int(state.get("max_hp", 100)), int(state.get("hp", 0)) + int(item.get("heal", 30)))
	_persist(peer_id)
	_sync_game_state()
	character_changed.emit(get_character_view())
	return true

func assign_skillbar(slot_index: int, skill_id: String) -> bool:
	if slot_index < 0 or slot_index > 2:
		return false
	var peer_id := local_peer_id()
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if pa == null:
		return false
	var state := pa.ensure_peer(peer_id)
	var skillbar: Array = state.get("skillbar", ["", "", ""]).duplicate(true)
	while skillbar.size() < 3:
		skillbar.append("")
	if skill_id != "" and skill_id not in state.get("unlocked_skills", []):
		return false
	skillbar[slot_index] = skill_id
	state["skillbar"] = skillbar
	_persist(peer_id)
	skillbar_changed.emit(skillbar.duplicate(true))
	character_changed.emit(get_character_view())
	return true

func unlock_skill_with_points(skill_id: String) -> bool:
	var peer_id := local_peer_id()
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if pa == null:
		return false
	var state := pa.ensure_peer(peer_id)
	if skill_id not in state.get("known_skills", []):
		return false
	if skill_id in state.get("unlocked_skills", []):
		return false
	if int(state.get("available_skill_points", 0)) <= 0:
		return false
	state["available_skill_points"] = int(state["available_skill_points"]) - 1
	var unlocked: Array = state.get("unlocked_skills", []).duplicate(true)
	unlocked.append(skill_id)
	state["unlocked_skills"] = unlocked
	_persist(peer_id)
	character_changed.emit(get_character_view())
	return true

func spend_mp(cost: int) -> bool:
	var peer_id := local_peer_id()
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	if pa == null:
		return false
	var state := pa.ensure_peer(peer_id)
	if int(state.get("mp", 0)) < cost:
		return false
	state["mp"] = int(state["mp"]) - cost
	_sync_game_state()
	character_changed.emit(get_character_view())
	return true

func save_now() -> void:
	_persist(local_peer_id())

func load_now() -> void:
	_loaded = false
	_bootstrap_local_character()

func physical_attack_power() -> int:
	return int(get_character_view().get("derived_stats", {}).get("physical_attack", 14))

func skill_power(skill: Dictionary) -> int:
	var derived: Dictionary = get_character_view().get("derived_stats", {})
	var base := int(skill.get("base_power", 12))
	var scale_key := String(skill.get("scaling", "strength"))
	var scale_val := int(get_character_view().get("final_stats", {}).get(scale_key, 8))
	return base + int(round(scale_val * 1.6))

func _inventory_view(state: Dictionary) -> Array:
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	var out: Array = []
	for stack in state.get("inventory", []):
		if not stack is Dictionary:
			continue
		var item_id := String(stack.get("id", stack.get("item_id", "")))
		var item := db.item_data(item_id) if db else {}
		out.append({
			"item_id": item_id,
			"quantity": int(stack.get("qty", 1)),
			"display_name": String(item.get("display_name", item.get("name", item_id))),
			"category": String(item.get("category", "MISC")),
			"rarity": String(item.get("rarity", "COMMON")),
			"icon": String(item.get("icon", "")),
			"description": String(item.get("description", "")),
			"required_level": int(item.get("required_level", 1)),
			"allowed_slot": String(item.get("allowed_slot", "")),
			"stat_modifiers": item.get("stat_modifiers", {}),
			"sell_value": int(item.get("sell_value", 0)),
			"stackable": bool(item.get("stackable", false)),
		})
	return out

func _inventory_slots_used(inventory: Array) -> int:
	var used := 0
	for entry in inventory:
		if entry is Dictionary:
			used += 1 if bool(entry.get("stackable", false)) else int(entry.get("quantity", 1))
	return used

func _equipped_item_id(slot_value) -> String:
	if slot_value is Dictionary:
		return String(slot_value.get("item_id", ""))
	return String(slot_value)

func _recalculate(peer_id: int) -> void:
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	var pipeline = get_tree().get_first_node_in_group("stat_pipeline_service")
	if pa == null or pipeline == null:
		return
	var state := pa.ensure_peer(peer_id)
	pipeline.apply_derived_to_state(state)
	pa.state_changed.emit(peer_id, state)

func _persist(peer_id: int) -> void:
	var pa := get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
	var chars := get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
	if pa and chars:
		chars.persist(pa.ensure_peer(peer_id))

func _sync_game_state() -> void:
	var gs := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	var view := get_character_view()
	if gs == null:
		return
	gs.level = int(view.get("level", 1))
	gs.xp = int(view.get("xp", 0))
	gs.max_hp = int(view.get("max_hp", 100))
	gs.hp = mini(int(view.get("hp", gs.max_hp)), gs.max_hp)
	gs.gold = int(view.get("gold", 0))
	gs.inventory.clear()
	for entry in view.get("inventory", []):
		for _i in range(int(entry.get("quantity", 1))):
			gs.inventory.append(String(entry.get("item_id", "")))
	gs.player_stats_changed.emit(gs.hp, gs.max_hp, gs.level, gs.xp, gs.gold)
	gs.inventory_changed.emit(gs.inventory.duplicate())

func _unlock_skills_for_level(state: Dictionary) -> void:
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	if db == null:
		return
	var unlocked: Array = state.get("unlocked_skills", []).duplicate(true)
	for skill in db.class_skills(String(state.get("class_id", "adventurer"))):
		var req := int(skill.get("unlock", {}).get("lv", 99))
		var sid := String(skill.get("id", ""))
		if sid == "" or sid in unlocked:
			continue
		if int(state.get("level", 1)) >= req:
			unlocked.append(sid)
	state["unlocked_skills"] = unlocked

func _merge_character_fields(state: Dictionary, saved: Dictionary) -> void:
	for key in ["character_id", "account_id", "name", "display_name", "class_id", "level", "xp", "gold", "base_stats", "available_stat_points", "available_skill_points", "known_skills", "unlocked_skills", "skillbar", "inventory", "equipment", "inventory_capacity"]:
		if saved.has(key):
			state[key] = saved[key]
	if not state.has("display_name"):
		state["display_name"] = String(state.get("name", "Hüter"))

func _apply_equipment_visuals() -> void:
	var visual_svc := get_tree().get_first_node_in_group("production_equipment_visual")
	if visual_svc and visual_svc.has_method("refresh_from_character"):
		visual_svc.refresh_from_character()

func _progression_cfg() -> Dictionary:
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	return db.progression_config() if db else {}
