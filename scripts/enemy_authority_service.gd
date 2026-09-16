class_name BrambleEnemyAuthorityService
extends Node
var brains:Dictionary={}
func _ready()->void:add_to_group("enemy_authority_service")
func register_enemy(enemy:Node2D)->void:
    brains[enemy.get_instance_id()]={"state":"idle","target_peer":0,"last_attack":0.0}
func unregister_enemy(enemy:Node2D)->void:brains.erase(enemy.get_instance_id())
func state_for(enemy:Node2D)->Dictionary:return brains.get(enemy.get_instance_id(),{"state":"idle","target_peer":0,"last_attack":0.0})
func set_state(enemy:Node2D,state:String,target_peer:int=0)->void:
    var b:=state_for(enemy);b["state"]=state;b["target_peer"]=target_peer;brains[enemy.get_instance_id()]=b
func can_attack(enemy:Node2D,cooldown:float)->bool:
    var b:=state_for(enemy);var now:=Time.get_ticks_msec()/1000.0
    if now-float(b.get("last_attack",0.0))<cooldown:return false
    b["last_attack"]=now;brains[enemy.get_instance_id()]=b;return true
