class_name BrambleCombatRuntimeService
extends Node

signal combat_event(kind: String, payload: Dictionary)
signal skill_cooldown_changed(slot: int, remaining: float, total: float)

const BASIC_DAMAGE := 14
const SKILL_SLOT := 0
var _skill_cd_until := 0.0
var _skill_cd_total := 3.9

func _ready() -> void:
	add_to_group("combat_runtime_service")
	var db := get_tree().get_first_node_in_group("content_db") as BrambleContentDB
	if db:
		var skills := db.class_skills("adventurer")
		if skills.size() > SKILL_SLOT:
			_skill_cd_total = float(skills[SKILL_SLOT].get("cd", 3.9))

func _process(delta: float) -> void:
	if _skill_cd_until > 0.0:
		_skill_cd_until = maxf(0.0, _skill_cd_until - delta)
		skill_cooldown_changed.emit(SKILL_SLOT, _skill_cd_until, _skill_cd_total)

func resolve_basic_attack(attacker: Node2D, target_entity_id: int = 0) -> Dictionary:
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	var target := _resolve_target(attacker, targeting, target_entity_id, 125.0)
	if target == null:
		return {"ok": false, "error": "no_target"}
	if target.has_method("take_damage"):
		target.take_damage(BASIC_DAMAGE, attacker)
	combat_event.emit("basic_attack", {"target_id": _entity_id(target), "damage": BASIC_DAMAGE})
	return {"ok": true, "damage": BASIC_DAMAGE, "target_id": _entity_id(target)}

func resolve_skill(attacker: Node2D, slot: int, target_entity_id: int = 0) -> Dictionary:
	if slot != SKILL_SLOT:
		return {"ok": false, "error": "unsupported_slot"}
	if _skill_cd_until > 0.0:
		return {"ok": false, "error": "cooldown", "remaining": _skill_cd_until}
	var targeting = get_tree().get_first_node_in_group("combat_targeting_service")
	var target := _resolve_target(attacker, targeting, target_entity_id, 145.0)
	if target == null:
		return {"ok": false, "error": "no_target"}
	var damage := 26
	if target.has_method("take_damage"):
		target.take_damage(damage, attacker)
	_spawn_skill_vfx(attacker, target)
	_skill_cd_until = _skill_cd_total
	skill_cooldown_changed.emit(SKILL_SLOT, _skill_cd_until, _skill_cd_total)
	combat_event.emit("skill", {"slot": slot, "skill_id": "cut", "damage": damage, "target_id": _entity_id(target)})
	return {"ok": true, "damage": damage, "skill_id": "cut"}

func handle_enemy_death(enemy: Node2D, _killer: Node = null) -> void:
	if enemy == null:
		return
	var enemy_id := String(enemy.get("enemy_id"))
	var xp_reward := int(enemy.get("xp_reward"))
	var gold_reward := int(enemy.get("gold_reward"))
	var state := get_tree().get_first_node_in_group("game_state") as BrambleGameState
	if state:
		state.register_enemy_kill(enemy_id, xp_reward, 0)
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
	fx.texture = BrambleWorldPresentationConfig.game_tex("ui/hud/primary_attack_button.png")
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

func skill_ready() -> bool:
	return _skill_cd_until <= 0.0
