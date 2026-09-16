class_name BrambleProgressionService
extends Node
signal progression_changed(peer_id:int,level:int,xp:int)
signal level_up(peer_id:int,new_level:int)
func _ready()->void:add_to_group("progression_service")
func xp_needed(level:int)->int:return maxi(100,level*100)
func grant(peer_id:int,xp:int=0,jxp:int=0,reputation:int=0,gold:int=0)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return
    var s:=pa.ensure_peer(peer_id);s["gold"]=int(s.get("gold",0))+maxi(0,gold);s["jxp"]=int(s.get("jxp",0))+maxi(0,jxp);s["reputation"]=int(s.get("reputation",0))+maxi(0,reputation);s["xp"]=int(s.get("xp",0))+maxi(0,xp)
    var level:=int(s.get("level",1));var needed:=xp_needed(level)
    while int(s["xp"])>=needed:
        s["xp"]=int(s["xp"])-needed;level+=1;s["level"]=level;s["max_hp"]=int(s.get("max_hp",100))+8;s["hp"]=int(s["max_hp"]);level_up.emit(peer_id,level);needed=xp_needed(level)
    pa.state_changed.emit(peer_id,s)
    var chars:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
    if chars:chars.persist(s)
    progression_changed.emit(peer_id,level,int(s["xp"]))
