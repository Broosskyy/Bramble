class_name BrambleTransactionAuditService
extends Node
signal recorded(entry:Dictionary)
const MAX_MEMORY_ENTRIES:=2048
const PATH:="user://bramble_v11_4_audit.jsonl"
var entries:Array=[]
func _ready()->void:add_to_group("transaction_audit_service")
func record(domain:String,action:String,actor:Dictionary,details:Dictionary,result:String="ok")->Dictionary:
    var ids:=get_tree().get_first_node_in_group("identity_service") as BrambleIdentityService
    var entry={"audit_id":ids.new_id("aud") if ids else "aud_%d"%Time.get_ticks_msec(),"at":Time.get_unix_time_from_system(),"domain":domain,"action":action,"result":result,"account_id":String(actor.get("account_id","")),"character_id":String(actor.get("character_id","")),"session_id":String(actor.get("session_id","")),"peer_id":int(actor.get("peer_id",0)),"details":details.duplicate(true)}
    entries.append(entry);while entries.size()>MAX_MEMORY_ENTRIES:entries.pop_front()
    var f:=FileAccess.open(PATH,FileAccess.READ_WRITE)
    if f==null:f=FileAccess.open(PATH,FileAccess.WRITE)
    if f:f.seek_end();f.store_line(JSON.stringify(entry))
    var outbox:=get_tree().get_first_node_in_group("outbox_service") as BrambleOutboxService
    if outbox:outbox.enqueue("audit.recorded",entry)
    recorded.emit(entry);return entry
func recent(limit:int=100)->Array:return entries.slice(maxi(0,entries.size()-limit),entries.size()).duplicate(true)
