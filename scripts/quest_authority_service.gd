class_name BrambleQuestAuthorityService
extends Node
func _ready()->void:add_to_group("quest_authority_service")
func current(peer_id:int)->Dictionary:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if pa==null or db==null:return {}
    return db.quest_data(int(pa.ensure_peer(peer_id).get("quest_index",0))).duplicate(true)
func on_npc(peer_id:int,npc_id:String)->Dictionary:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return {"ok":false,"error":"authority_unavailable"}
    var s:=pa.ensure_peer(peer_id);var q:=current(peer_id)
    if q.is_empty():return {"ok":true,"complete":true}
    if String(q.get("target",""))!=npc_id or String(q.get("type","")) not in ["talk","level_and_talk"]:return {"ok":true,"advanced":false,"quest":q}
    var req:Dictionary=q.get("requirements",{})
    if int(s.get("level",1))<int(req.get("lv",1)):return {"ok":false,"error":"requirements","quest":q}
    return _advance(peer_id,s,q,"npc")
func on_enemy_killed(peer_id:int,enemy_id:String,map_id:String)->Dictionary:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return {}
    var s:=pa.ensure_peer(peer_id);var q:=current(peer_id)
    if q.is_empty():return {}
    var t:=String(q.get("type",""));var matches:=(t=="kill" and String(q.get("target",""))==enemy_id) or (t=="boss" and String(q.get("target",""))==enemy_id) or (t=="kill_map" and String(q.get("map",""))==map_id)
    if not matches:return {}
    var counters:Dictionary=s.get("counters",{});var key:=String(q.get("counter",q.get("id","progress")))
    counters[key]=int(counters.get(key,0))+1;s["counters"]=counters
    var needed:=int(q.get("count",1))
    if int(counters[key])>=needed:return _advance(peer_id,s,q,"kill")
    _persist(s);return {"ok":true,"advanced":false,"progress":int(counters[key]),"required":needed,"quest":q}
func _advance(peer_id:int,s:Dictionary,q:Dictionary,source:String)->Dictionary:
    s["quest_index"]=int(s.get("quest_index",0))+1;_persist(s)
    var audit:=get_tree().get_first_node_in_group("transaction_audit_service")
    if audit and audit.has_method("record"):audit.record("quest_advanced",{"peer_id":peer_id,"quest_id":String(q.get("id","")),"source":source})
    return {"ok":true,"advanced":true,"completed_quest":String(q.get("id","")),"quest":current(peer_id)}
func _persist(s:Dictionary)->void:
    var characters:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
    if characters:characters.persist(s)
