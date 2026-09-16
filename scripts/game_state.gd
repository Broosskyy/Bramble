class_name BrambleGameState
extends Node

signal quest_changed(title: String, text: String)
signal player_stats_changed(hp: int, max_hp: int, level: int, xp: int, gold: int)
signal toast_requested(text: String)
signal enemy_killed(enemy_id: String)

var max_hp := 100
var hp := 100
var level := 1
var xp := 0
var gold := 0
var potions := 3

# 0 = talk to Lina, 1 = kill 3 sprouts, 2 = return, 3 = complete
var quest_stage := 0
var sprout_kills := 0

func _ready() -> void:
	_emit_all()

func _emit_all() -> void:
	player_stats_changed.emit(hp, max_hp, level, xp, gold)
	_emit_quest()

func _emit_quest() -> void:
	match quest_stage:
		0:
			quest_changed.emit("ERSTER AUFTRAG", "Sprich mit Lina bei der Heilstation.")
		1:
			quest_changed.emit("WILDE SPROSSLINGE", "Besiege Sprösslinge: %d/3" % sprout_kills)
		2:
			quest_changed.emit("WILDE SPROSSSLINGE", "Kehre zu Lina zurück.")
		_:
			quest_changed.emit("HAINWEILER", "Erkunde das Dorf und die östlichen Felder.")

func talk_to_npc(npc_id: String, npc_name: String) -> String:
	if npc_id == "lina":
		if quest_stage == 0:
			quest_stage = 1
			_emit_quest()
			toast_requested.emit("Quest angenommen: Wilde Sprösslinge")
			return "Lina: Die Sprösslinge werden aggressiv. Besiege drei von ihnen."
		elif quest_stage == 2:
			quest_stage = 3
			gold += 80
			add_xp(55)
			_emit_quest()
			player_stats_changed.emit(hp, max_hp, level, xp, gold)
			toast_requested.emit("Quest abgeschlossen · +80 Gold · +55 XP")
			return "Lina: Sehr gut. Hainweiler ist dir dankbar."
		elif quest_stage == 1:
			return "Lina: Noch nicht. Besiege drei Sprösslinge am östlichen Feldrand."
	return "%s: Willkommen in Hainweiler." % npc_name

func register_enemy_kill(enemy_id: String, xp_reward: int, gold_reward: int) -> void:
	add_xp(xp_reward)
	gold += gold_reward
	if enemy_id == "monster_sprout" and quest_stage == 1:
		sprout_kills += 1
		if sprout_kills >= 3:
			quest_stage = 2
		_emit_quest()
	enemy_killed.emit(enemy_id)
	player_stats_changed.emit(hp, max_hp, level, xp, gold)

func add_xp(amount: int) -> void:
	xp += amount
	var needed := level * 100
	while xp >= needed:
		xp -= needed
		level += 1
		max_hp += 12
		hp = max_hp
		needed = level * 100
		toast_requested.emit("LEVEL UP · Level %d" % level)

func damage_player(amount: int) -> void:
	hp = maxi(0, hp - amount)
	player_stats_changed.emit(hp, max_hp, level, xp, gold)
	if hp <= 0:
		hp = max_hp
		var player := get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = Vector2(0, 360)
		player_stats_changed.emit(hp, max_hp, level, xp, gold)
		toast_requested.emit("Du wurdest nach Hainweiler zurückgebracht.")

func heal_player(amount: int) -> void:
	hp = mini(max_hp, hp + amount)
	player_stats_changed.emit(hp, max_hp, level, xp, gold)

func use_potion() -> bool:
	if potions <= 0 or hp >= max_hp:
		return false
	potions -= 1
	heal_player(45)
	toast_requested.emit("Heiltrank benutzt · +45 HP")
	return true
