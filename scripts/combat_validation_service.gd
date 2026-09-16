class_name BrambleCombatValidationService
extends Node
func _ready()->void:add_to_group("combat_validation_service")
func validate_target(peer_id:int,target,maximum_range:float)->Dictionary:
    if target==null or not is_instance_valid(target) or not (target is Node2D):return {"ok":false,"error":"invalid_target"}
    if not target.is_in_group("enemy"):return {"ok":false,"error":"target_not_enemy"}
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return {"ok":false,"error":"authority_unavailable"}
    var s:=pa.ensure_peer(peer_id);var from:=Vector2(float(s.get("x",0.0)),float(s.get("y",360.0)))
    var distance:=from.distance_to(target.global_position)
    if distance>maximum_range:return {"ok":false,"error":"out_of_range","distance":distance}
    return {"ok":true,"distance":distance}
func target_from_payload(peer_id:int,p:Dictionary,maximum_range:float):
    var requested:=int(p.get("target_entity_id",0));var registry:=get_tree().get_first_node_in_group("network_entity_registry")
    if requested!=0 and registry and registry.has_method("node_for_entity"):
        var node=registry.node_for_entity(requested);if bool(validate_target(peer_id,node,maximum_range).get("ok",false)):return node
    var authority:=get_tree().get_first_node_in_group("server_authority")
    if authority and authority.has_method("nearest_enemy_for_validation"):return authority.nearest_enemy_for_validation(peer_id,maximum_range)
    return null
