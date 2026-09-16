class_name BrambleOutboxService
extends Node
signal event_enqueued(event:Dictionary)
const PATH:="user://bramble_v11_4_outbox.jsonl"
var pending:Array=[]
func _ready()->void:add_to_group("outbox_service")
func enqueue(topic:String,payload:Dictionary)->Dictionary:
    var ids:=get_tree().get_first_node_in_group("identity_service") as BrambleIdentityService
    var e={"event_id":ids.new_id("evt") if ids else "evt_%d"%Time.get_ticks_msec(),"topic":topic,"at":Time.get_unix_time_from_system(),"payload":payload.duplicate(true)}
    pending.append(e);_append(e);event_enqueued.emit(e);return e
func drain(limit:int=100)->Array:
    var n:=mini(limit,pending.size());var out:=pending.slice(0,n).duplicate(true);pending=pending.slice(n,pending.size());return out
func _append(e:Dictionary)->void:
    var f:=FileAccess.open(PATH,FileAccess.READ_WRITE)
    if f==null:f=FileAccess.open(PATH,FileAccess.WRITE)
    if f:f.seek_end();f.store_line(JSON.stringify(e))
