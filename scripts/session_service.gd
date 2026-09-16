class_name BrambleSessionService
extends Node
signal session_opened(peer_id:int,session:Dictionary)
signal session_closed(peer_id:int,session:Dictionary)
const RECONNECT_GRACE:=120.0
var by_peer:Dictionary={}
var by_token:Dictionary={}

func _ready()->void:add_to_group("session_service")

func open(peer_id:int,account_id:String,character_id:String)->Dictionary:
    close(peer_id)
    var ids:=get_tree().get_first_node_in_group("identity_service") as BrambleIdentityService
    var session_id:=ids.new_id("ses") if ids else "ses_%d_%d"%[peer_id,Time.get_ticks_msec()]
    var token:=ids.new_id("rec") if ids else "%08x%08x"%[randi(),randi()]
    var s={"session_id":session_id,"peer_id":peer_id,"account_id":account_id,"character_id":character_id,"reconnect_token":token,"connected":true,"last_seen":Time.get_unix_time_from_system()}
    by_peer[peer_id]=s;by_token[token]=s;session_opened.emit(peer_id,s);return s

func try_resume(peer_id:int,token:String)->Dictionary:
    if token=="" or not by_token.has(token):return {}
    var s:Dictionary=by_token[token]
    if Time.get_unix_time_from_system()-float(s.get("last_seen",0.0))>RECONNECT_GRACE:return {}
    by_peer.erase(int(s.get("peer_id",0)));s["peer_id"]=peer_id;s["connected"]=true;s["last_seen"]=Time.get_unix_time_from_system();by_peer[peer_id]=s
    return s

func mark_disconnected(peer_id:int)->void:
    if by_peer.has(peer_id):by_peer[peer_id]["connected"]=false;by_peer[peer_id]["last_seen"]=Time.get_unix_time_from_system()

func close(peer_id:int)->void:
    if not by_peer.has(peer_id):return
    var s:Dictionary=by_peer[peer_id];by_peer.erase(peer_id);by_token.erase(String(s.get("reconnect_token","")));session_closed.emit(peer_id,s)
