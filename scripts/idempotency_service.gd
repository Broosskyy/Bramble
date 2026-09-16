class_name BrambleIdempotencyService
extends Node
const MAX_KEYS:=4096
var results:Dictionary={}
var order:Array=[]
func _ready()->void:add_to_group("idempotency_service")
func seen(key:String)->bool:return key!="" and results.has(key)
func get_result(key:String)->Dictionary:return results.get(key,{}).duplicate(true)
func remember(key:String,result:Dictionary)->void:
    if key=="":return
    if not results.has(key):order.append(key)
    results[key]=result.duplicate(true)
    while order.size()>MAX_KEYS:
        results.erase(String(order.pop_front()))
