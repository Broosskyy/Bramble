class_name BramblePartyManager
extends Node
const MAX_PARTY:=5
const REWARD_RANGE:=900.0
var members:Dictionary={}
func _ready()->void:add_to_group("party_manager")
func upsert(peer_id:int,data:Dictionary)->void:
    if not members.has(peer_id) and members.size()>=MAX_PARTY:return
    members[peer_id]=data.duplicate(true)
func remove(peer_id:int)->void:members.erase(peer_id)
func reward_multiplier()->float:return 1.0+maxi(0,members.size()-1)*0.05
