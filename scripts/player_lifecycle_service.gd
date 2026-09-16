class_name BramblePlayerLifecycleService
extends Node
signal lifecycle_changed(peer_id:int,stage:String,context:Dictionary)
var stage_by_peer:Dictionary={}
func _ready()->void:add_to_group("player_lifecycle_service")
func begin(peer_id:int)->void:_set_stage(peer_id,"connected",{})
func authenticated(peer_id:int,claim:Dictionary)->void:_set_stage(peer_id,"authenticated",claim)
func character_resolved(peer_id:int,state:Dictionary)->void:_set_stage(peer_id,"character_resolved",{"character_id":state.get("character_id","")})
func world_joined(peer_id:int,state:Dictionary)->void:_set_stage(peer_id,"world_joined",{"character_id":state.get("character_id",""),"map":state.get("map","village")})
func disconnected(peer_id:int)->void:_set_stage(peer_id,"disconnected",{})
func stage(peer_id:int)->String:return String(stage_by_peer.get(peer_id,"none"))
func can_gameplay(peer_id:int)->bool:return stage(peer_id)=="world_joined"
func _set_stage(peer_id:int,next:String,context:Dictionary)->void:stage_by_peer[peer_id]=next;lifecycle_changed.emit(peer_id,next,context)
