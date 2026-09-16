class_name BrambleInventoryService
extends Node
signal inventory_changed(peer_id:int, inventory:Array)
signal transaction_rejected(peer_id:int, reason:String)

func _ready()->void:add_to_group("inventory_service")

func add_item(peer_id:int,item_id:String,qty:int=1,meta:Dictionary={},transaction_id:String="")->bool:
    var idem:=get_tree().get_first_node_in_group("idempotency_service") as BrambleIdempotencyService
    if idem and idem.seen(transaction_id):return bool(idem.get_result(transaction_id).get("ok",false))
    if not _valid_item(item_id) or qty<=0:return _reject(peer_id,"invalid_item_or_quantity")
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return _reject(peer_id,"authority_unavailable")
    var state:=pa.ensure_peer(peer_id);var inv:Array=state.get("inventory",[])
    var instances:=get_tree().get_first_node_in_group("item_instance_service") as BrambleItemInstanceService
    if instances and instances._requires_instance(item_id):
        for _i in range(qty):
            var inst:=instances.create(item_id,String(state.get("character_id","")),meta)
            inv.append({"id":item_id,"item_id":item_id,"instance_id":String(inst.get("instance_id","")),"qty":1,"meta":meta.duplicate(true)})
        state["inventory"]=inv;_commit(peer_id,state);_audit(peer_id,"add_instance",{"item_id":item_id,"qty":qty,"transaction_id":transaction_id});_remember(transaction_id,true);return true
    for stack in inv:
        if String(stack.get("id",""))==item_id and stack.get("meta",{})==meta:
            stack["qty"]=int(stack.get("qty",0))+qty;state["inventory"]=inv;_commit(peer_id,state);_remember(transaction_id,true);return true
    inv.append({"id":item_id,"qty":qty,"meta":meta.duplicate(true)})
    state["inventory"]=inv;_commit(peer_id,state);_remember(transaction_id,true);return true

func remove_item(peer_id:int,item_id:String,qty:int=1,transaction_id:String="")->bool:
    var idem:=get_tree().get_first_node_in_group("idempotency_service") as BrambleIdempotencyService
    if idem and idem.seen(transaction_id):return bool(idem.get_result(transaction_id).get("ok",false))
    if qty<=0:return _reject(peer_id,"invalid_quantity")
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return _reject(peer_id,"authority_unavailable")
    var state:=pa.ensure_peer(peer_id);var inv:Array=state.get("inventory",[])
    var remaining:=qty
    for i in range(inv.size()-1,-1,-1):
        var stack:Dictionary=inv[i]
        if String(stack.get("id",""))!=item_id:continue
        var take:=mini(remaining,int(stack.get("qty",0)));stack["qty"]=int(stack.get("qty",0))-take;remaining-=take
        if int(stack["qty"])<=0:inv.remove_at(i)
        if remaining<=0:break
    if remaining>0:return _reject(peer_id,"insufficient_quantity")
    state["inventory"]=inv;_commit(peer_id,state);_remember(transaction_id,true);return true

func remove_instance(peer_id:int,instance_id:String)->bool:
    if instance_id=="":return _reject(peer_id,"invalid_instance_id")
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return _reject(peer_id,"authority_unavailable")
    var state:=pa.ensure_peer(peer_id);var inv:Array=state.get("inventory",[])
    for i in range(inv.size()-1,-1,-1):
        if String(inv[i].get("instance_id",""))!=instance_id:continue
        inv.remove_at(i);state["inventory"]=inv;_commit(peer_id,state);return true
    return _reject(peer_id,"instance_not_owned")

func count(peer_id:int,item_id:String)->int:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return 0
    var total:=0
    for stack in pa.ensure_peer(peer_id).get("inventory",[]):
        if String(stack.get("id",""))==item_id:total+=int(stack.get("qty",0))
    return total

func owns(peer_id:int,item_id:String,qty:int=1)->bool:return count(peer_id,item_id)>=qty

func transfer(from_peer:int,to_peer:int,item_id:String,qty:int=1)->bool:
    if from_peer==to_peer or qty<=0:return _reject(from_peer,"invalid_transfer")
    if not owns(from_peer,item_id,qty):return _reject(from_peer,"ownership_validation_failed")
    if not remove_item(from_peer,item_id,qty):return false
    if add_item(to_peer,item_id,qty):return true
    add_item(from_peer,item_id,qty);return _reject(from_peer,"transfer_rolled_back")

func _valid_item(item_id:String)->bool:
    if item_id=="":return false
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    return db!=null and not db.item_data(item_id).is_empty()

func _reject(peer_id:int,reason:String)->bool:transaction_rejected.emit(peer_id,reason);return false

func _commit(peer_id:int,state:Dictionary)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa:pa.state_changed.emit(peer_id,state)
    var chars:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
    if chars:chars.persist(state)
    inventory_changed.emit(peer_id,state.get("inventory",[]).duplicate(true))
func _audit(peer_id:int,action:String,details:Dictionary,result:String="ok")->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var audit:=get_tree().get_first_node_in_group("transaction_audit_service") as BrambleTransactionAuditService
    if pa and audit:audit.record("inventory",action,pa.ensure_peer(peer_id),details,result)

func _remember(transaction_id:String,ok:bool)->void:
    var idem:=get_tree().get_first_node_in_group("idempotency_service") as BrambleIdempotencyService
    if idem and transaction_id!="":idem.remember(transaction_id,{"ok":ok})
