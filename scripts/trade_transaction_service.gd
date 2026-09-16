class_name BrambleTradeTransactionService
extends Node
signal trade_result(trade_id:String,result:Dictionary)
func _ready()->void:add_to_group("trade_transaction_service")
func exchange(trade_id:String,a_peer:int,b_peer:int,a_offer:Dictionary,b_offer:Dictionary)->Dictionary:
    if trade_id=="" or a_peer==b_peer:return _reject(trade_id,"invalid_trade")
    var idem:=get_tree().get_first_node_in_group("idempotency_service") as BrambleIdempotencyService
    var idem_key:="trade:"+trade_id
    if idem and idem.seen(idem_key):return idem.get_result(idem_key)
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var inv:=get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
    var instances:=get_tree().get_first_node_in_group("item_instance_service") as BrambleItemInstanceService
    if pa==null or inv==null or instances==null:return _reject(trade_id,"services_unavailable")
    var a:=pa.ensure_peer(a_peer);var b:=pa.ensure_peer(b_peer);var a_before:=a.duplicate(true);var b_before:=b.duplicate(true)
    var a_gold:=maxi(0,int(a_offer.get("gold",0)));var b_gold:=maxi(0,int(b_offer.get("gold",0)))
    if int(a.get("gold",0))<a_gold or int(b.get("gold",0))<b_gold:return _reject(trade_id,"insufficient_gold")
    if not _validate_offer(a_peer,a_offer,inv,instances):return _reject(trade_id,"a_ownership_failed")
    if not _validate_offer(b_peer,b_offer,inv,instances):return _reject(trade_id,"b_ownership_failed")
    a["gold"]=int(a.get("gold",0))-a_gold+b_gold;b["gold"]=int(b.get("gold",0))-b_gold+a_gold;pa.states[a_peer]=a;pa.states[b_peer]=b
    if not _move_offer(a_peer,b_peer,a_offer,inv,instances,trade_id+":a") or not _move_offer(b_peer,a_peer,b_offer,inv,instances,trade_id+":b"):
        pa.states[a_peer]=a_before;pa.states[b_peer]=b_before;_persist_pair(a_before,b_before);return _reject(trade_id,"commit_failed_rolled_back")
    _persist_pair(pa.states[a_peer],pa.states[b_peer])
    var result={"ok":true,"trade_id":trade_id,"a_gold":a_gold,"b_gold":b_gold,"instance_aware":true}
    if idem:idem.remember(idem_key,result)
    var audit:=get_tree().get_first_node_in_group("transaction_audit_service") as BrambleTransactionAuditService
    if audit:audit.record("trade","exchange",pa.states[a_peer],result)
    trade_result.emit(trade_id,result);return result
func _validate_offer(peer:int,offer:Dictionary,inv:BrambleInventoryService,instances:BrambleItemInstanceService)->bool:
    for iid in offer.get("instances",[]):
        if instances.find_owned(peer,String(iid)).is_empty():return false
    for row in offer.get("items",[]):
        var item_id:=String(row.get("id",""));if instances._requires_instance(item_id):return false
        if not inv.owns(peer,item_id,int(row.get("qty",1))):return false
    return true
func _move_offer(from_peer:int,to_peer:int,offer:Dictionary,inv:BrambleInventoryService,instances:BrambleItemInstanceService,tid:String)->bool:
    for iid in offer.get("instances",[]):
        if not bool(instances.transfer_owned(from_peer,to_peer,String(iid)).get("ok",false)):return false
    for row in offer.get("items",[]):
        var item_id:=String(row.get("id",""));var qty:=int(row.get("qty",1))
        if not inv.remove_item(from_peer,item_id,qty,tid+":rm:"+item_id):return false
        if not inv.add_item(to_peer,item_id,qty,{},tid+":add:"+item_id):return false
    return true
func _persist_pair(a:Dictionary,b:Dictionary)->void:
    var chars:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
    if chars:chars.persist(a);chars.persist(b)
func _reject(trade_id:String,reason:String)->Dictionary:
    var r={"ok":false,"trade_id":trade_id,"reason":reason};trade_result.emit(trade_id,r);return r
