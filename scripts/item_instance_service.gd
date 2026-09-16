class_name BrambleItemInstanceService
extends Node
signal instance_created(instance:Dictionary)
func _ready()->void:add_to_group("item_instance_service")
func create(item_id:String,owner_character_id:String,meta:Dictionary={})->Dictionary:
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if item_id=="" or db==null or db.item_data(item_id).is_empty():return {}
    var ids:=get_tree().get_first_node_in_group("identity_service") as BrambleIdentityService
    var instance={"instance_id":ids.new_id("itm") if ids else "itm_%d_%d"%[Time.get_ticks_msec(),randi()],"item_id":item_id,"owner_character_id":owner_character_id,"created_at":Time.get_unix_time_from_system(),"meta":meta.duplicate(true)}
    instance_created.emit(instance);return instance
func normalize_inventory(state:Dictionary)->bool:
    var changed:=false;var owner:=String(state.get("character_id",""));var inv:Array=state.get("inventory",[])
    for stack in inv:
        if not stack is Dictionary:continue
        var item_id:=String(stack.get("id",stack.get("item_id","")))
        if item_id=="":continue
        stack["id"]=item_id;stack["item_id"]=item_id
        if _requires_instance(item_id) and String(stack.get("instance_id",""))=="":
            var instance:=create(item_id,owner,stack.get("meta",{}));stack["instance_id"]=String(instance.get("instance_id",""));stack["qty"]=1;changed=true
    state["inventory"]=inv;return changed
func find_owned(peer_id:int,instance_id:String)->Dictionary:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return {}
    for stack in pa.ensure_peer(peer_id).get("inventory",[]):
        if String(stack.get("instance_id",""))==instance_id:return stack
    return {}
func _requires_instance(item_id:String)->bool:
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if db==null:return false
    var t:=String(db.item_data(item_id).get("type",""))
    return t in ["weapon","offhand","armor","head","chest","hands","legs","feet","accessory","ring","amulet"]

func transfer_owned(from_peer:int,to_peer:int,instance_id:String)->Dictionary:
    if from_peer==to_peer or instance_id=="":return {"ok":false,"reason":"invalid_instance_transfer"}
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return {"ok":false,"reason":"authority_unavailable"}
    var from_state:=pa.ensure_peer(from_peer);var to_state:=pa.ensure_peer(to_peer)
    var from_inv:Array=from_state.get("inventory",[]);var found:Dictionary={};var found_index:=-1
    for i in range(from_inv.size()):
        if String(from_inv[i].get("instance_id",""))==instance_id:found=from_inv[i].duplicate(true);found_index=i;break
    if found_index<0:return {"ok":false,"reason":"instance_not_owned"}
    from_inv.remove_at(found_index);from_state["inventory"]=from_inv
    found["qty"]=1;found["owner_character_id"]=String(to_state.get("character_id",""))
    var to_inv:Array=to_state.get("inventory",[]);to_inv.append(found);to_state["inventory"]=to_inv
    pa.states[from_peer]=from_state;pa.states[to_peer]=to_state
    var chars:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
    if chars:chars.persist(from_state);chars.persist(to_state)
    return {"ok":true,"instance":found.duplicate(true)}
