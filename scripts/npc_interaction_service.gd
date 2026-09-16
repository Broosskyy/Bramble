class_name BrambleNpcInteractionService
extends Node
func _ready()->void:add_to_group("npc_interaction_service")
func interact(peer_id:int,npc_id:String)->Dictionary:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if pa==null or db==null:return {"ok":false,"error":"unavailable"}
    var s:=pa.ensure_peer(peer_id);var npc:=_find_npc(db,npc_id,String(s.get("map","village")))
    if npc.is_empty():return {"ok":false,"error":"npc_not_on_map"}
    var role:=String(npc.get("interaction","dialog"));var result:={"ok":true,"npc":npc,"interaction":role}
    if role=="quest":
        var quests:=get_tree().get_first_node_in_group("quest_authority_service") as BrambleQuestAuthorityService
        if quests:result["quest_result"]=quests.on_npc(peer_id,npc_id)
    elif role=="shop":result["shop_id"]=npc_id
    return result
func _find_npc(db:BrambleContentDB,npc_id:String,map_id:String)->Dictionary:
    var list:Array=db.npcs.get(map_id,[])
    for entry in list:
        if String(entry.get("id",""))==npc_id:return entry.duplicate(true)
    return {}
