class_name BrambleEquipmentService
extends Node
signal equipment_changed(peer_id:int,equipment:Dictionary)
signal equipment_rejected(peer_id:int,reason:String)
const SLOTS:= ["weapon","offhand","head","chest","hands","legs","feet","accessory"]
func _ready()->void:add_to_group("equipment_service")
func equip(peer_id:int,slot:String,item_id:String,instance_id:String="")->bool:
    if not slot in SLOTS or item_id=="":return _reject(peer_id,"invalid_slot_or_item")
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    var inv:=get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
    if db==null or inv==null:return _reject(peer_id,"domain_unavailable")
    var item:=db.item_data(item_id)
    if item.is_empty():return _reject(peer_id,"unknown_item")
    if instance_id!="":
        var instances:=get_tree().get_first_node_in_group("item_instance_service") as BrambleItemInstanceService
        var owned:=instances.find_owned(peer_id,instance_id) if instances else {}
        if owned.is_empty() or String(owned.get("item_id",owned.get("id","")))!=item_id:return _reject(peer_id,"instance_not_owned")
    elif not inv.owns(peer_id,item_id,1):return _reject(peer_id,"item_not_owned")
    elif _requires_instance(item_id):return _reject(peer_id,"instance_required")
    if not _slot_accepts(slot,String(item.get("type",""))):return _reject(peer_id,"slot_type_mismatch")
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return _reject(peer_id,"authority_unavailable")
    var s:=pa.ensure_peer(peer_id);var eq:Dictionary=s.get("equipment",{});eq[slot]={"item_id":item_id,"instance_id":instance_id} if instance_id!="" else item_id;s["equipment"]=eq;_commit(peer_id,s);_audit(peer_id,"equip",{"slot":slot,"item_id":item_id,"instance_id":instance_id});return true
func unequip(peer_id:int,slot:String)->bool:
    if not slot in SLOTS:return _reject(peer_id,"invalid_slot")
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return _reject(peer_id,"authority_unavailable")
    var s:=pa.ensure_peer(peer_id);var eq:Dictionary=s.get("equipment",{});eq.erase(slot);s["equipment"]=eq;_commit(peer_id,s);return true
func _requires_instance(item_id:String)->bool:
    var instances:=get_tree().get_first_node_in_group("item_instance_service") as BrambleItemInstanceService
    return instances!=null and instances._requires_instance(item_id)
func _slot_accepts(slot:String,item_type:String)->bool:
    if slot in ["weapon","offhand"]:return item_type in ["weapon","offhand"]
    if slot=="accessory":return item_type in ["accessory","ring","amulet"]
    return item_type in ["armor",slot]
func _reject(peer_id:int,reason:String)->bool:equipment_rejected.emit(peer_id,reason);return false
func _commit(peer_id:int,s:Dictionary)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa:pa.state_changed.emit(peer_id,s)
    var chars:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
    if chars:chars.persist(s)
    equipment_changed.emit(peer_id,s.get("equipment",{}).duplicate(true))

func _audit(peer_id:int,action:String,details:Dictionary,result:String="ok")->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var audit:=get_tree().get_first_node_in_group("transaction_audit_service") as BrambleTransactionAuditService
    if pa and audit:audit.record("equipment",action,pa.ensure_peer(peer_id),details,result)
