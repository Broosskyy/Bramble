class_name BrambleNetworkEntityRegistry
extends Node
var next_id:=1000
var entities:Dictionary={}
func _ready()->void:add_to_group("network_entity_registry");call_deferred("scan_world")
func scan_world()->void:
    for n in get_tree().get_nodes_in_group("enemy"):
        if not n.has_meta("net_entity_id"):register(n)
func register(node:Node,forced_id:=0)->int:
    var id:=forced_id if forced_id>0 else next_id
    next_id=maxi(next_id,id+1);entities[id]=node;node.set_meta("net_entity_id",id);return id
func unregister(node:Node)->void:
    for id in entities.keys():
        if entities[id]==node:entities.erase(id);break
func enemy_snapshot()->Array:
    var arr:Array=[]
    for id in entities.keys():
        var n=entities[id]
        if is_instance_valid(n) and n.is_in_group("enemy"):
            arr.append({"entity_id":id,"enemy_id":String(n.get("enemy_id")),"x":n.global_position.x,"y":n.global_position.y,"hp":int(n.get("hp")),"max_hp":int(n.get("max_hp"))})
    return arr
