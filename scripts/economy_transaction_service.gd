class_name BrambleEconomyTransactionService
extends Node
signal transaction_committed(transaction_id:String,peer_id:int,delta:Dictionary)
signal transaction_rejected(transaction_id:String,peer_id:int,reason:String)
func _ready()->void:add_to_group("economy_transaction_service")
func apply(peer_id:int,delta:Dictionary,transaction_id:String)->Dictionary:
    var idem:=get_tree().get_first_node_in_group("idempotency_service") as BrambleIdempotencyService
    if idem and idem.seen(transaction_id):return idem.get_result(transaction_id)
    if transaction_id=="":return _reject(transaction_id,peer_id,"transaction_id_required")
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return _reject(transaction_id,peer_id,"authority_unavailable")
    var state:=pa.ensure_peer(peer_id);var before:=state.duplicate(true)
    for currency in ["gold","reputation"]:
        var change:=int(delta.get(currency,0));var next:=int(state.get(currency,0))+change
        if next<0:return _reject(transaction_id,peer_id,"insufficient_"+currency)
        state[currency]=next
    var inventory:=get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
    for row in delta.get("remove_items",[]):
        if inventory==null or not inventory.remove_item(peer_id,String(row.get("id","")),int(row.get("qty",1)),transaction_id+":remove:"+String(row.get("id",""))):
            pa.states[peer_id]=before;return _reject(transaction_id,peer_id,"item_remove_failed")
    for row in delta.get("add_items",[]):
        if inventory==null or not inventory.add_item(peer_id,String(row.get("id","")),int(row.get("qty",1)),row.get("meta",{}),transaction_id+":add:"+String(row.get("id",""))):
            pa.states[peer_id]=before;return _reject(transaction_id,peer_id,"item_add_failed")
    pa.states[peer_id]=state;pa.state_changed.emit(peer_id,state)
    var chars:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService;if chars:chars.persist(state)
    var result={"ok":true,"transaction_id":transaction_id,"delta":delta.duplicate(true)};if idem:idem.remember(transaction_id,result)
    var audit:=get_tree().get_first_node_in_group("transaction_audit_service") as BrambleTransactionAuditService;if audit:audit.record("economy","commit",state,result)
    transaction_committed.emit(transaction_id,peer_id,delta);return result
func _reject(tid:String,peer_id:int,reason:String)->Dictionary:
    var result={"ok":false,"transaction_id":tid,"reason":reason};var idem:=get_tree().get_first_node_in_group("idempotency_service") as BrambleIdempotencyService;if idem and tid!="":idem.remember(tid,result)
    transaction_rejected.emit(tid,peer_id,reason);return result
