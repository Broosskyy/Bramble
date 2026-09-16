class_name BrambleCombatRuntimeService
extends Node

signal combat_event(kind: String, payload: Dictionary)
signal skill_cooldown_changed(slot: int, remaining: float, total: float)

var _skill_cd_until: Array[float] = [0.0, 0.0, 0.0]
var _skill_cd_total: Array[float] = [3.9, 5.2, 6.0]

func _ready() -> void:
	add_to_group("combat_runtime_service")
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	if db:
		for i in range(3):
			var skills := db.class_skills("adventurer")
			if i < skills.size():
				_skill_cd_total[i] = float(skills[i].get("cooldown", skills[i].get("cd", 4.0)))

func _process(delta: float) -> void:
	for i in range(_skill_cd_until.size()):
		if _skill_cd_until[i] > 0.0:
			_skill_cd_until[i] = maxf(0.0, _skill_cd_until[i] - delta)
			skill_cooldown_changed.emit(i, _skill_cd_until[i], _skill_cd_total[i])

func resolve_basic_attack(attacker: Node2D, target_entity_id: int = 0) -> Dictionary:
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	var target := _resolve_target(attacker, targeting, target_entity_id, 125.0)
	if target == null:
		return {"ok": false, "error": "no_target"}
	var cs = get_tree().get_first_node_in_group("character_state_service")
	var damage: int = 14
	if cs and cs.has_method("physical_attack_power"):
		damage = cs.physical_attack_power()
	if target.has_method("take_damage"):
		target.take_damage(damage, attacker)
	combat_event.emit("basic_attack", {"target_id": _entity_id(target), "damage": damage})
	return {"ok": true, "damage": damage, "target_id": _entity_id(target)}

func resolve_skill(attacker: Node2D, slot: int, target_entity_id: int = 0) -> Dictionary:
	if slot < 0 or slot >= _skill_cd_until.size():
		return {"ok": false, "error": "unsupported_slot"}
	if _skill_cd_until[slot] > 0.0:
		return {"ok": false, "error": "cooldown", "remaining": _skill_cd_until[slot]}
	var cs = get_tree().get_first_node_in_group("character_state_service")
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	if cs == null or db == null:
		return {"ok": false, "error": "services_unavailable"}
	var view: Dictionary = cs.get_character_view()
	var skillbar: Array = view.get("skillbar", [])
	if slot >= skillbar.size() or String(skillbar[slot]) == "":
		return {"ok": false, "error": "empty_slot"}
	var skill_id := String(skillbar[slot])
	if skill_id not in view.get("unlocked_skills", []):
		return {"ok": false, "error": "locked_skill"}
	var skill := db.skill_by_id(String(view.get("class_id", "adventurer")), skill_id)
	if skill.is_empty():
		return {"ok": false, "error": "unknown_skill"}
	var mp_cost := int(skill.get("resource_cost", 0))
	if not cs.spend_mp(mp_cost):
		return {"ok": false, "error": "insufficient_mp"}
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	var target := _resolve_target(attacker, targeting, target_entity_id, float(skill.get("range", 145.0)))
	if target == null:
		return {"ok": false, "error": "no_target"}
	var damage: int = cs.skill_power(skill)
	if target.has_method("take_damage"):
		target.take_damage(damage, attacker)
	_spawn_skill_vfx(attacker, target)
	_skill_cd_until[slot] = float(skill.get("cooldown", skill.get("cd", _skill_cd_total[slot])))
	skill_cooldown_changed.emit(slot, _skill_cd_until[slot], _skill_cd_total[slot])
	combat_event.emit("skill", {"slot": slot, "skill_id": skill_id, "damage": damage, "target_id": _entity_id(target)})
	return {"ok": true, "damage": damage, "skill_id": skill_id}

func handle_enemy_death(enemy: Node2D, _killer: Node = null) -> void:
	if enemy == null:
		return
	var enemy_id := String(enemy.get("enemy_id"))
	var xp_reward := int(enemy.get("xp_reward"))
	var gold_reward := int(enemy.get("gold_reward"))
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state:
		state.register_enemy_kill(enemy_id, xp_reward, gold_reward)
	var net := get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
	var peer_id := multiplayer.get_unique_id() if net and net.mode != "offline" else 1
	if net and net.mode == "host":
		var rewards := get_tree().get_first_node_in_group("shared_reward_service") as BrambleSharedRewardService
		if rewards:
			rewards.grant_kill(enemy.global_position, {"xp": xp_reward, "gold": 0, "jxp": 0})
		var quests := get_tree().get_first_node_in_group("quest_authority_service") as BrambleQuestAuthorityService
		if quests:
			quests.on_enemy_killed(peer_id, enemy_id, "wilds")
	_spawn_loot_drops(enemy, gold_reward)
	combat_event.emit("enemy_killed", {"enemy_id": enemy_id, "killer_peer": peer_id})

func _resolve_target(attacker: Node2D, targeting: Node, entity_id: int, max_range: float) -> Node2D:
	var registry := get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
	if entity_id > 0 and registry:
		var node = registry.node_for_entity(entity_id)
		if node is Node2D and attacker.global_position.distance_to(node.global_position) <= max_range:
			if not node.has_method("is_combat_alive") or node.is_combat_alive():
				return node
	if targeting and targeting.has_method("get_target"):
		var selected: Node2D = targeting.get_target()
		if selected and attacker.global_position.distance_to(selected.global_position) <= max_range:
			return selected
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is Node2D and attacker.global_position.distance_to(node.global_position) <= max_range:
			if node.has_method("is_combat_alive") and node.is_combat_alive():
				return node
	return null

func _spawn_loot_drops(enemy: Node2D, gold_reward: int) -> void:
	var parent := enemy.get_parent()
	if parent == null:
		return
	var origin := enemy.global_position
	var herb := BrambleLootPickup.new()
	herb.item_id = "herb"
	herb.gold_amount = 0
	herb.global_position = origin + Vector2(-14, 6)
	parent.add_child(herb)
	var gold := BrambleLootPickup.new()
	gold.item_id = ""
	gold.gold_amount = gold_reward
	gold.global_position = origin + Vector2(14, -6)
	parent.add_child(gold)
	if randf() < 0.35:
		var ore := BrambleLootPickup.new()
		ore.item_id = "ore"
		ore.gold_amount = 0
		ore.global_position = origin + Vector2(0, 18)
		parent.add_child(ore)

func _spawn_skill_vfx(_attacker: Node2D, target: Node2D) -> void:
	var fx := Sprite2D.new()
	fx.texture = BrambleWorldPresentationConfig.game_tex("ui/skills/skill_button.png")
	fx.modulate = Color(1.0, 0.85, 0.35, 0.75)
	fx.scale = Vector2.ONE * 0.35
	fx.global_position = target.global_position + Vector2(0, -60)
	fx.z_index = 500
	get_tree().current_scene.add_child(fx)
	var tween := create_tween()
	tween.tween_property(fx, "modulate:a", 0.0, 0.35)
	tween.tween_callback(fx.queue_free)

func _entity_id(node: Node) -> int:
	var registry := get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
	return registry.entity_id_for(node) if registry else 0

func skill_ready(slot: int = 0) -> bool:
	if slot < 0 or slot >= _skill_cd_until.size():
		return false
	return _skill_cd_until[slot] <= 0.0
