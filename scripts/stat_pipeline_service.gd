class_name BrambleStatPipelineService
extends Node

const BASE_KEYS := ["vitality", "strength", "defense", "magic", "resistance", "speed"]

func _ready() -> void:
	add_to_group("stat_pipeline_service")

func progression_config() -> Dictionary:
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	return db.progression_config() if db else {}

func calculate(state: Dictionary) -> Dictionary:
	var cfg := progression_config()
	var base_cfg: Dictionary = cfg.get("base_stats", {})
	var allocated: Dictionary = state.get("base_stats", {})
	var level := int(state.get("level", 1))
	var growth: Dictionary = cfg.get("stat_growth_per_level", {})
	var base: Dictionary = {}
	for key in BASE_KEYS:
		var seed_val := int(base_cfg.get(key, 8))
		var alloc := int(allocated.get(key, 0))
		var growth_bonus := int(growth.get(key, 1)) * maxi(0, level - 1)
		base[key] = seed_val + alloc + growth_bonus
	var equipment_mods := _equipment_modifiers(state)
	var modifier_hooks := _modifier_hook_totals(state)
	var final_stats: Dictionary = {}
	for key in BASE_KEYS:
		final_stats[key] = base.get(key, 0) + equipment_mods.get(key, 0) + modifier_hooks.get(key, 0)
	var derived := _derive(final_stats, state, equipment_mods)
	return {
		"base": base,
		"equipment": equipment_mods,
		"modifier_hooks": modifier_hooks,
		"final": final_stats,
		"derived": derived,
	}

func xp_to_next_level(level: int) -> int:
	var cfg := progression_config()
	var table: Array = cfg.get("xp_per_level", [])
	if level - 1 >= 0 and level - 1 < table.size():
		return int(table[level - 1])
	return maxi(100, level * 100)

func apply_derived_to_state(state: Dictionary) -> Dictionary:
	var calc := calculate(state)
	var derived: Dictionary = calc.get("derived", {})
	state["max_hp"] = int(derived.get("max_hp", state.get("max_hp", 100)))
	state["max_mp"] = int(derived.get("max_mp", state.get("max_mp", 40)))
	state["hp"] = mini(int(state.get("hp", state["max_hp"])), int(state["max_hp"]))
	state["mp"] = mini(int(state.get("mp", state["max_mp"])), int(state["max_mp"]))
	state["derived_stats"] = derived.duplicate(true)
	state["final_stats"] = calc.get("final", {}).duplicate(true)
	return state

func _equipment_modifiers(state: Dictionary) -> Dictionary:
	var totals: Dictionary = {}
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	if db == null:
		return totals
	for slot_value in state.get("equipment", {}).values():
		var item_id := _equipped_item_id(slot_value)
		if item_id == "":
			continue
		var item := db.item_data(item_id)
		for key in item.get("stat_modifiers", {}).keys():
			totals[key] = int(totals.get(key, 0)) + int(item["stat_modifiers"][key])
	return totals

func _equipped_item_id(slot_value) -> String:
	if slot_value is Dictionary:
		return String(slot_value.get("item_id", ""))
	return String(slot_value)

func _modifier_hook_totals(_state: Dictionary) -> Dictionary:
	return {}

func _derive(final_stats: Dictionary, state: Dictionary, equipment_mods: Dictionary) -> Dictionary:
	var vit := int(final_stats.get("vitality", 10))
	var str_val := int(final_stats.get("strength", 8))
	var def_val := int(final_stats.get("defense", 6))
	var mag := int(final_stats.get("magic", 5))
	var res := int(final_stats.get("resistance", 5))
	var spd := int(final_stats.get("speed", 8))
	var level := int(state.get("level", 1))
	var weapon_bonus := int(equipment_mods.get("physical_attack", 0))
	var magic_bonus := int(equipment_mods.get("magic_attack", 0))
	return {
		"max_hp": 70 + vit * 7 + level * 4 + int(equipment_mods.get("max_hp", 0)),
		"max_mp": 30 + mag * 6 + level * 2 + int(equipment_mods.get("max_mp", 0)),
		"physical_attack": 6 + str_val * 2 + weapon_bonus,
		"magic_attack": 4 + mag * 2 + magic_bonus,
		"physical_defense": 3 + def_val * 2,
		"magic_defense": 2 + res * 2,
		"move_speed": 220 + spd * 4,
		"attack_speed": 1.0 + spd * 0.01,
	}
