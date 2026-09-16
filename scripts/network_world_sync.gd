class_name BrambleNetworkWorldSync
extends Node

var tick:=0.0

func _ready()->void:
    add_to_group("network_world_sync")

func _process(delta:float)->void:
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
    if net==null or net.mode=="offline":
        return
    tick-=delta
    if tick<=0.0 and net.mode=="host":
        tick=0.10
        _send_snapshot()

func _send_snapshot()->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var registry:=get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
    if pa==null or registry==null:
        return
    var snapshot:={"players":pa.snapshot(),"enemies":registry.enemy_snapshot()}
    _rpc_snapshot.rpc(snapshot)
    var remote_players = get_tree().get_first_node_in_group("remote_player_service")
    if remote_players and remote_players.has_method("sync_players"):
        remote_players.sync_players(snapshot.get("players",[]), multiplayer.get_unique_id())
    var e2e := get_tree().get_first_node_in_group("multiplayer_e2e_service")
    if e2e and e2e.has_method("note_snapshot"):
        var remote_count := 0
        for s in snapshot.get("players", []):
            if int(s.get("peer_id", -1)) != multiplayer.get_unique_id() and bool(s.get("connected", true)):
                remote_count += 1
        e2e.note_snapshot(snapshot.get("players", []).size(), remote_count)

@rpc("authority","call_remote","unreliable")
func _rpc_snapshot(snapshot:Dictionary)->void:
    var local_id:=multiplayer.get_unique_id()
    var prediction:=get_tree().get_first_node_in_group("prediction_reconciliation") as BramblePredictionReconciliation
    for s in snapshot.get("players",[]):
        if int(s.get("peer_id",-1))==local_id and prediction:
            prediction.reconcile(s)
    var remote_players = get_tree().get_first_node_in_group("remote_player_service")
    if remote_players and remote_players.has_method("sync_players"):
        remote_players.sync_players(snapshot.get("players",[]), local_id)
    var e2e := get_tree().get_first_node_in_group("multiplayer_e2e_service")
    if e2e and e2e.has_method("note_snapshot"):
        var remote_count := 0
        for s in snapshot.get("players", []):
            if int(s.get("peer_id", -1)) != local_id and bool(s.get("connected", true)):
                remote_count += 1
        e2e.note_snapshot(snapshot.get("players", []).size(), remote_count)
    _apply_enemies(snapshot.get("enemies",[]))

func _apply_enemies(arr:Array)->void:
    var registry:=get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
    if registry==null:
        return
    var seen:Dictionary={}
    for s in arr:
        var entity_id:=int(s.get("entity_id",0))
        seen[entity_id]=true
        if registry.entities.has(entity_id) and is_instance_valid(registry.entities[entity_id]):
            var enemy=registry.entities[entity_id]
            enemy.global_position=Vector2(float(s.get("x",0)),float(s.get("y",0)))
            enemy.set("hp",int(s.get("hp",1)))
    for s in arr:
        var entity_id:=int(s.get("entity_id",0))
        if entity_id<=0 or registry.entities.has(entity_id):
            continue
        var enemy:=BrambleEnemy.new()
        enemy.enemy_id=String(s.get("enemy_id","monster_sprout"))
        enemy.enemy_name=enemy.enemy_id
        enemy.asset_id="monster_sprout"
        enemy.max_hp=int(s.get("max_hp",34))
        enemy.global_position=Vector2(float(s.get("x",0)),float(s.get("y",0)))
        var parent:=get_tree().current_scene
        parent.add_child(enemy)
        enemy.hp=int(s.get("hp",enemy.max_hp))
        registry.register(enemy,entity_id)
    for entity_id in registry.entities.keys().duplicate():
        if not seen.has(entity_id) and is_instance_valid(registry.entities[entity_id]):
            registry.entities[entity_id].queue_free()
            registry.entities.erase(entity_id)
