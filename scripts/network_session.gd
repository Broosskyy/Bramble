class_name BrambleNetworkSession
extends Node
signal mode_changed(mode:String)
signal peer_joined(peer_id:int)
signal peer_left(peer_id:int)
signal intent_received(peer_id:int,kind:String,payload:Dictionary)
signal character_list_received(characters:Array)
signal character_operation_result(operation:String,result:Dictionary)
signal world_join_received(state:Dictionary)
var mode:="offline"
var port:=27840
var skip_character_lobby:=false
var seq:=0
var reconnect_token:=""
var session_id:=""

func _ready()->void:
    add_to_group("network_session")
    multiplayer.peer_connected.connect(_peer_connected)
    multiplayer.peer_disconnected.connect(_peer_disconnected)
    multiplayer.connected_to_server.connect(func():
        mode="client";mode_changed.emit(mode)
        _rpc_request_join.rpc_id(1,{"reconnect_token":reconnect_token,"credentials":{"method":"guest"},"character_lobby":not skip_character_lobby and reconnect_token==""})
    )
    multiplayer.connection_failed.connect(close)
    multiplayer.server_disconnected.connect(close)
func host(p:=27840)->int:
    close();var peer:=ENetMultiplayerPeer.new();var err:=peer.create_server(p,8)
    if err!=OK:return err
    multiplayer.multiplayer_peer=peer;port=p;mode="host";mode_changed.emit(mode);return OK
func join(address:String,p:=27840)->int:
    close();var peer:=ENetMultiplayerPeer.new();var err:=peer.create_client(address,p)
    if err!=OK:return err
    multiplayer.multiplayer_peer=peer;port=p;mode="client";mode_changed.emit(mode);return OK
func close()->void:
    if multiplayer.multiplayer_peer:multiplayer.multiplayer_peer.close()
    multiplayer.multiplayer_peer=OfflineMultiplayerPeer.new();mode="offline";session_id="";mode_changed.emit(mode)
func send_intent(kind:String,payload:Dictionary)->void:
    if mode=="offline":return
    seq+=1;payload=payload.duplicate(true);payload["seq"]=seq;payload["client_time"]=Time.get_ticks_msec()
    var pred:=get_tree().get_first_node_in_group("prediction_reconciliation")
    if pred and pred.has_method("record_input"):pred.record_input(seq,kind,payload)
    if mode=="host":intent_received.emit(multiplayer.get_unique_id(),kind,payload)
    else:_rpc_intent.rpc_id(1,kind,payload)
func request_character_list()->void:
    if mode=="client":_rpc_character_command.rpc_id(1,"list",{})
func create_character(name:String,class_id:String="adventurer",request_id:String="")->void:
    if mode=="client":_rpc_character_command.rpc_id(1,"create",{"name":name,"class_id":class_id,"request_id":request_id})
func select_character(character_id:String)->void:
    if mode=="client":_rpc_character_command.rpc_id(1,"select",{"character_id":character_id})
func delete_character(character_id:String,request_id:String="")->void:
    if mode=="client":_rpc_character_command.rpc_id(1,"delete",{"character_id":character_id,"request_id":request_id})
@rpc("any_peer","call_remote","reliable")
func _rpc_intent(kind:String,payload:Dictionary)->void:
    if not multiplayer.is_server():return
    intent_received.emit(multiplayer.get_remote_sender_id(),kind,payload)
@rpc("any_peer","call_remote","reliable")
func _rpc_request_join(claim:Dictionary)->void:
    if not multiplayer.is_server():return
    var sync:=get_tree().get_first_node_in_group("join_sync_service")
    if sync and sync.has_method("host_accept_join"):sync.host_accept_join(multiplayer.get_remote_sender_id(),claim)
@rpc("any_peer","call_remote","reliable")
func _rpc_character_command(operation:String,payload:Dictionary)->void:
    if not multiplayer.is_server():return
    var sync:=get_tree().get_first_node_in_group("join_sync_service")
    if sync and sync.has_method("host_character_command"):sync.host_character_command(multiplayer.get_remote_sender_id(),operation,payload)
@rpc("authority","call_remote","reliable")
func receive_character_list(characters:Array)->void:character_list_received.emit(characters)
@rpc("authority","call_remote","reliable")
func receive_character_result(operation:String,result:Dictionary)->void:character_operation_result.emit(operation,result)
@rpc("authority","call_remote","reliable")
func receive_world_join(state:Dictionary)->void:
    reconnect_token=String(state.get("token",""));session_id=String(state.get("session_id",""));world_join_received.emit(state)
func _peer_connected(id:int)->void:peer_joined.emit(id)
func _peer_disconnected(id:int)->void:peer_left.emit(id)
