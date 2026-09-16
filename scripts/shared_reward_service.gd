class_name BrambleSharedRewardService
extends Node
func _ready()->void:add_to_group("shared_reward_service")
func grant_kill(origin:Vector2,base:Dictionary)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return
    var eligible:Array=[]
    for id in pa.states.keys():
        var s:Dictionary=pa.states[id]
        if bool(s.get("connected",true)) and Vector2(float(s.get("x",0)),float(s.get("y",0))).distance_to(origin)<=900.0:eligible.append(int(id))
    var mult:=1.0+maxi(0,eligible.size()-1)*0.05
    for id in eligible:
        var r: Dictionary = base.duplicate(true);r["xp"]=int(round(int(r.get("xp",0))*mult));r["jxp"]=int(round(int(r.get("jxp",0))*mult));pa.grant_reward(id,r)
