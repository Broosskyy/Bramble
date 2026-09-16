class_name BrambleJoinSyncService
extends Node
var auth_context:Dictionary={}
func _ready()->void:add_to_group("join_sync_service")
func host_accept_join(peer_id:int,request:Dictionary)->void:
    var lifecycle:=get_tree().get_first_node_in_group("player_lifecycle_service") as BramblePlayerLifecycleService
    var auth:=get_tree().get_first_node_in_group("auth_gateway") as BrambleAuthGateway
    var sessions:=get_tree().get_first_node_in_group("session_service") as BrambleSessionService
    if lifecycle:lifecycle.begin(peer_id)
    var resume_token:=String(request.get("reconnect_token",""));var session:Dictionary=sessions.try_resume(peer_id,resume_token) if sessions else {};var claim:Dictionary={}
    if not session.is_empty():
        claim={"account_id":session.get("account_id",""),"character_id":session.get("character_id",""),"auth_method":"resume"};auth_context[peer_id]={"claim":claim,"session":session}
        if lifecycle:lifecycle.authenticated(peer_id,claim)
        _join_character(peer_id,String(session.get("character_id","")),true);return
    var credentials:Dictionary=request.get("credentials",{})
    if credentials.is_empty():credentials={"method":"guest","account_id":String(request.get("account_id",""))}
    claim=auth.authenticate(peer_id,credentials) if auth else {}
    if claim.is_empty():_reject(peer_id,"authentication_failed");return
    auth_context[peer_id]={"claim":claim,"session":{}}
    if lifecycle:lifecycle.authenticated(peer_id,claim)
    if bool(request.get("character_lobby",true)):_send_list(peer_id)
    else:
        var characters:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
        var list:=characters.list_characters(String(claim.get("account_id",""))) if characters else []
        if list.is_empty():
            var created:=characters.create_character(String(claim.get("account_id","")),{"name":"Adventurer"},_parity_seed()) if characters else {}
            _join_character(peer_id,String(created.get("character_id","")),false)
        else:_join_character(peer_id,String(list[0].get("character_id","")),false)
func host_character_command(peer_id:int,operation:String,payload:Dictionary)->void:
    if not auth_context.has(peer_id):_reject(peer_id,"not_authenticated");return
    var claim:Dictionary=auth_context[peer_id].get("claim",{});var account_id:=String(claim.get("account_id",""));var characters:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
    var audit:=get_tree().get_first_node_in_group("transaction_audit_service") as BrambleTransactionAuditService
    var request_id:=String(payload.get("request_id",""));var idem:=get_tree().get_first_node_in_group("idempotency_service") as BrambleIdempotencyService
    if operation in ["create","delete"] and idem and idem.seen(request_id):
        _send_result(peer_id,operation,idem.get_result(request_id));return
    match operation:
        "list":_send_list(peer_id)
        "create":
            var state:=characters.create_character(account_id,payload,_parity_seed()) if characters else {};var result={"ok":not state.is_empty(),"character":characters._summary(state) if characters and not state.is_empty() else {},"characters":characters.list_characters(account_id) if characters else []}
            if idem:idem.remember(request_id,result)
            if audit:audit.record("character","create",{"peer_id":peer_id,"account_id":account_id},result,"ok" if result.ok else "rejected")
            _send_result(peer_id,operation,result)
        "select":_join_character(peer_id,String(payload.get("character_id","")),false)
        "delete":
            var cid:=String(payload.get("character_id",""));var ok:=characters.delete_character(account_id,cid) if characters else false;var result={"ok":ok,"characters":characters.list_characters(account_id) if characters else []}
            if idem:idem.remember(request_id,result)
            if audit:audit.record("character","delete",{"peer_id":peer_id,"account_id":account_id,"character_id":cid},{"character_id":cid},"ok" if ok else "rejected")
            _send_result(peer_id,operation,result)
        _:_send_result(peer_id,operation,{"ok":false,"reason":"unknown_operation"})
func _join_character(peer_id:int,character_id:String,resumed:bool)->void:
    var ctx:Dictionary=auth_context.get(peer_id,{});var claim:Dictionary=ctx.get("claim",{});var account_id:=String(claim.get("account_id",""));var characters:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
    var state:=characters.select_character(account_id,character_id) if characters else {}
    if state.is_empty():_send_result(peer_id,"select",{"ok":false,"reason":"character_not_found"});return
    var sessions:=get_tree().get_first_node_in_group("session_service") as BrambleSessionService;var session:Dictionary=ctx.get("session",{})
    if session.is_empty() and sessions:session=sessions.open(peer_id,account_id,character_id)
    auth_context[peer_id]={"claim":claim,"session":session}
    var lifecycle:=get_tree().get_first_node_in_group("player_lifecycle_service") as BramblePlayerLifecycleService
    if lifecycle:lifecycle.character_resolved(peer_id,state)
    state["peer_id"]=peer_id;state["session_id"]=String(session.get("session_id",""));state["account_id"]=account_id;state["connected"]=true
    var instances:=get_tree().get_first_node_in_group("item_instance_service") as BrambleItemInstanceService
    if instances:instances.normalize_inventory(state)
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa:pa.states[peer_id]=state;pa.potion_cooldowns[peer_id]=0.0
    if characters:characters.persist(state)
    if lifecycle:lifecycle.world_joined(peer_id,state)
    var audit:=get_tree().get_first_node_in_group("transaction_audit_service") as BrambleTransactionAuditService
    if audit:audit.record("session","world_join",state,{"map":state.get("map","village"),"resumed":resumed})
    var payload={"token":String(session.get("reconnect_token","")),"session_id":String(session.get("session_id","")),"character_id":character_id,"players":pa.snapshot() if pa else [],"protocol":"bramble-v11.5"}
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
    if net:
        if peer_id == multiplayer.get_unique_id():
            net.receive_world_join(payload)
        else:
            net.receive_world_join.rpc_id(peer_id,payload)
func _send_list(peer_id:int)->void:
    var ctx:Dictionary=auth_context.get(peer_id,{});var claim:Dictionary=ctx.get("claim",{});var characters:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService;var list:=characters.list_characters(String(claim.get("account_id",""))) if characters else []
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
    if net:net.receive_character_list.rpc_id(peer_id,list)
func _send_result(peer_id:int,operation:String,result:Dictionary)->void:
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
    if net:net.receive_character_result.rpc_id(peer_id,operation,result)
func _reject(peer_id:int,reason:String)->void:_send_result(peer_id,"join",{"ok":false,"reason":reason})
func _parity_seed()->Dictionary:
    var seed:Dictionary={"connected":true};var parity:=get_tree().get_first_node_in_group("web_parity_state") as BrambleWebParityState
    if parity:
        seed["level"]=int(parity.profile.get("lv",1));seed["job"]=int(parity.profile.get("job",1));seed["class_id"]=String(parity.profile.get("class_id","adventurer"));seed["stats"]=parity.profile.get("stats",{}).duplicate(true);seed["inventory"]=parity.profile.get("inventory",[]).duplicate(true);seed["equipment"]=parity.profile.get("equipment",{}).duplicate(true);seed["specialists"]=parity.profile.get("specialists",[]).duplicate(true);seed["pets"]=parity.profile.get("pets",[]).duplicate(true)
    return seed
