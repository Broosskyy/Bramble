class_name BrambleLootAuthority
extends Node
signal roll_opened(id:String,item:Dictionary,eligible:Array)
signal roll_resolved(id:String,winner:int,item:Dictionary)
var mode:="personal"
var rolls:Dictionary={}
func _ready()->void:add_to_group("loot_authority")
func set_mode(v:String)->bool:
    if v not in ["personal","shared","need_greed"]:return false
    mode=v;return true
func distribute(origin:Vector2,item:Dictionary)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return
    var eligible:Array=[]
    for id in pa.states.keys():
        var s:Dictionary=pa.states[id]
        if Vector2(float(s.get("x",0)),float(s.get("y",0))).distance_to(origin)<=900.0:eligible.append(int(id))
    if eligible.is_empty():return
    if mode=="personal":
        for id in eligible:_grant_loot(id,item,"loot_personal_%d_%d"%[Time.get_ticks_msec(),id])
    elif mode=="shared":
        var winner:=int(eligible[randi()%eligible.size()]);_grant_loot(winner,item,"loot_shared_%d_%d"%[Time.get_ticks_msec(),winner])
    else:
        var rid:="%d_%d"%[Time.get_ticks_msec(),randi()];rolls[rid]={"item":item.duplicate(true),"eligible":eligible,"choices":{}};roll_opened.emit(rid,item,eligible)
func choose(peer_id:int,rid:String,choice:String)->bool:
    if choice not in ["need","greed","pass"] or not rolls.has(rid):return false
    var r:Dictionary=rolls[rid]
    if peer_id not in r["eligible"]:return false
    r["choices"][peer_id]=choice
    if r["choices"].size()>=r["eligible"].size():_resolve(rid)
    return true
func _resolve(rid:String)->void:
    var r:Dictionary=rolls[rid];var need:Array=[];var greed:Array=[]
    for id in r["eligible"]:
        var c: String = String(r["choices"].get(id,"pass"));
        if c=="need":need.append(id)
        elif c=="greed":greed.append(id)
    var pool:=need if not need.is_empty() else greed
    if not pool.is_empty():
        var winner: int = int(pool[randi()%pool.size()]);_grant_loot(winner,r["item"],"loot_roll_"+rid+"_"+str(winner));roll_resolved.emit(rid,winner,r["item"])
    rolls.erase(rid)

func _grant_loot(peer_id:int,item:Dictionary,transaction_id:String)->void:
    var rewards:=get_tree().get_first_node_in_group("reward_transaction_service") as BrambleRewardTransactionService
    if rewards:rewards.grant(peer_id,{"items":[item]},transaction_id,"loot")
