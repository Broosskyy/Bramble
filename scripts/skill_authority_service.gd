class_name BrambleSkillAuthorityService
extends Node
var cooldown_until:Dictionary={}
const DEFAULT_MAX_RESOURCE:=100
func _ready()->void:add_to_group("skill_authority_service")
func validate_and_commit(peer_id:int,state:Dictionary,slot:int)->Dictionary:
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if db==null:return {"ok":false,"error":"content_unavailable"}
    var list:=db.class_skills(String(state.get("class_id","adventurer")))
    if slot<0 or slot>=list.size():return {"ok":false,"error":"invalid_slot"}
    var skill:Dictionary=list[slot]
    var unlock:Dictionary=skill.get("unlock",{})
    if int(state.get("level",1))<int(unlock.get("lv",1)) or int(state.get("job",1))<int(unlock.get("job",1)):
        return {"ok":false,"error":"skill_locked"}
    var cost:=maxi(0,int(skill.get("resource_cost",skill.get("mana_cost",0))))
    var resource:=int(state.get("skill_resource",DEFAULT_MAX_RESOURCE))
    if resource<cost:return {"ok":false,"error":"insufficient_resource","required":cost,"available":resource}
    if cost>0:state["skill_resource"]=resource-cost
    var skill_id:=String(skill.get("id",""));var key:="%d:%s"%[peer_id,skill_id]
    var now:=Time.get_ticks_msec()/1000.0;var until:=float(cooldown_until.get(key,0.0))
    if now<until:return {"ok":false,"error":"cooldown","remaining":until-now}
    cooldown_until[key]=now+maxf(0.05,float(skill.get("cd",1.0)))
    return {"ok":true,"skill":skill.duplicate(true)}
func clear_peer(peer_id:int)->void:
    var prefix:="%d:"%peer_id
    for key in cooldown_until.keys().duplicate():
        if String(key).begins_with(prefix):cooldown_until.erase(key)
