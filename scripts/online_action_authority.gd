class_name BrambleOnlineActionAuthority
extends Node

signal action_result(peer_id:int,kind:String,ok:bool,data:Dictionary)

func _ready()->void:
    add_to_group("online_action_authority")

func tame(peer_id:int,entity_id:int)->bool:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var registry:=get_tree().get_first_node_in_group("network_entity_registry") as BrambleNetworkEntityRegistry
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if pa==null or registry==null or db==null:
        return false
    if not registry.entities.has(entity_id):
        return false
    var s:=pa.ensure_peer(peer_id)
    var enemy=registry.entities[entity_id]
    if not is_instance_valid(enemy):
        return false
    var player_pos:=Vector2(float(s.get("x",0.0)),float(s.get("y",360.0)))
    if player_pos.distance_to(enemy.global_position)>115.0:
        return false
    var ratio:=float(enemy.get("hp"))/maxf(1.0,float(enemy.get("max_hp")))
    if ratio>0.35:
        return false
    var key:=String(enemy.get("enemy_id")).trim_prefix("monster_")
    var enemy_data:=db.enemy_data(key)
    if not bool(enemy_data.get("tameable",false)):
        return false
    var ok:=randf()<=float(enemy_data.get("base_tame_chance",0.25))
    if ok:
        var pets:Array=s.get("pets",[])
        if key not in pets:
            pets.append(key)
        s["pets"]=pets
        s["active_pet"]=key
    action_result.emit(peer_id,"tame",ok,{"pet_id":key})
    return ok

func specialist(peer_id:int,id:String,enable:bool)->bool:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:
        return false
    var s:=pa.ensure_peer(peer_id)
    if enable and id not in s.get("specialists",[]):
        return false
    s["active_specialist"]=id if enable else ""
    action_result.emit(peer_id,"specialist",true,{"id":id,"active":enable})
    return true
