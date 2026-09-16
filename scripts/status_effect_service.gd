class_name BrambleStatusEffectService
extends Node
var effects:Dictionary={}
func _ready()->void:add_to_group("status_effect_service")
func _process(_delta:float)->void:
    var now:=Time.get_ticks_msec()/1000.0
    for owner in effects.keys().duplicate():
        var list:Array=effects[owner]
        var keep:Array=[]
        for e in list:
            if float(e.get("expires_at",0.0))>now:keep.append(e)
        if keep.is_empty():effects.erase(owner)
        else:effects[owner]=keep
func apply(owner:String,effect_id:String,duration:float,magnitude:float=1.0,source:String="")->void:
    var list:Array=effects.get(owner,[]);var now:=Time.get_ticks_msec()/1000.0
    for i in range(list.size()):
        if String(list[i].get("id",""))==effect_id:
            list[i]={"id":effect_id,"expires_at":now+maxf(0.1,duration),"magnitude":magnitude,"source":source};effects[owner]=list;return
    list.append({"id":effect_id,"expires_at":now+maxf(0.1,duration),"magnitude":magnitude,"source":source});effects[owner]=list
func has(owner:String,effect_id:String)->bool:
    for e in effects.get(owner,[]):
        if String(e.get("id",""))==effect_id:return true
    return false
func magnitude(owner:String,effect_id:String,default_value:float=0.0)->float:
    for e in effects.get(owner,[]):
        if String(e.get("id",""))==effect_id:return float(e.get("magnitude",default_value))
    return default_value
func snapshot(owner:String)->Array:return effects.get(owner,[]).duplicate(true)
