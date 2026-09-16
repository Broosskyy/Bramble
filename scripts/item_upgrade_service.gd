class_name BrambleItemUpgradeService
extends Node
signal upgrade_result(peer_id:int,result:Dictionary)
const MAX_UPGRADE:=15
func _ready()->void:add_to_group("item_upgrade_service")
func upgrade(peer_id:int,instance_id:String,request_id:String)->Dictionary:
    if request_id=="" or instance_id=="":return _reject(peer_id,"invalid_request")
    var inst:=get_tree().get_first_node_in_group("item_instance_service") as BrambleItemInstanceService
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if inst==null or pa==null:return _reject(peer_id,"services_unavailable")
    var owned:=inst.find_owned(peer_id,instance_id);if owned.is_empty():return _reject(peer_id,"instance_not_owned")
    var meta:Dictionary=owned.get("meta",{});var level:=int(meta.get("upgrade_level",0))
    if level>=MAX_UPGRADE:return _reject(peer_id,"max_upgrade")
    var cost:=50*(level+1);var eco:=get_tree().get_first_node_in_group("economy_transaction_service") as BrambleEconomyTransactionService
    if eco==null:return _reject(peer_id,"economy_unavailable")
    var paid:=eco.apply(peer_id,{"gold":-cost},"upgrade:"+request_id);if not bool(paid.get("ok",false)):return paid
    var state:=pa.ensure_peer(peer_id);var inv:Array=state.get("inventory",[])
    for row in inv:
        if String(row.get("instance_id",""))==instance_id:
            var m:Dictionary=row.get("meta",{});m["upgrade_level"]=level+1;m["quality"]=String(m.get("quality","common"));row["meta"]=m;break
    state["inventory"]=inv;pa.states[peer_id]=state
    var chars:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService;if chars:chars.persist(state)
    var result={"ok":true,"instance_id":instance_id,"upgrade_level":level+1,"cost":cost,"request_id":request_id};upgrade_result.emit(peer_id,result);return result
func _reject(peer_id:int,reason:String)->Dictionary:
    var r={"ok":false,"reason":reason};upgrade_result.emit(peer_id,r);return r
