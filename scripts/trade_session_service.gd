class_name BrambleTradeSessionService
extends Node
signal trade_session_changed(trade_id:String,state:Dictionary)
var sessions:Dictionary={}
func _ready()->void:add_to_group("trade_session_service")
func open(trade_id:String,a_peer:int,b_peer:int)->Dictionary:
    if trade_id=="" or a_peer<=0 or b_peer<=0 or a_peer==b_peer:return _reject("invalid_trade")
    if sessions.has(trade_id):return sessions[trade_id].duplicate(true)
    var s={"trade_id":trade_id,"a_peer":a_peer,"b_peer":b_peer,"a_offer":{},"b_offer":{},"a_locked":false,"b_locked":false,"a_confirmed":false,"b_confirmed":false,"status":"offer","revision":1}
    sessions[trade_id]=s;trade_session_changed.emit(trade_id,s.duplicate(true));return s.duplicate(true)
func set_offer(trade_id:String,peer:int,offer:Dictionary)->Dictionary:
    var s:Dictionary=sessions.get(trade_id,{})
    if s.is_empty() or String(s.get("status"))!="offer":return _reject("trade_not_editable")
    var side:=_side(s,peer);if side=="":return _reject("not_participant")
    s[side+"_offer"]=offer.duplicate(true);s["a_locked"]=false;s["b_locked"]=false;s["a_confirmed"]=false;s["b_confirmed"]=false;s["revision"]=int(s.get("revision",0))+1;sessions[trade_id]=s
    trade_session_changed.emit(trade_id,s.duplicate(true));return s.duplicate(true)
func lock(trade_id:String,peer:int)->Dictionary:
    var s:Dictionary=sessions.get(trade_id,{});var side:=_side(s,peer);if side=="":return _reject("not_participant")
    s[side+"_locked"]=true
    if bool(s.get("a_locked")) and bool(s.get("b_locked")):s["status"]="locked"
    sessions[trade_id]=s;trade_session_changed.emit(trade_id,s.duplicate(true));return s.duplicate(true)
func confirm(trade_id:String,peer:int)->Dictionary:
    var s:Dictionary=sessions.get(trade_id,{});var side:=_side(s,peer)
    if side=="" or String(s.get("status"))!="locked":return _reject("trade_not_locked")
    s[side+"_confirmed"]=true;sessions[trade_id]=s
    if bool(s.get("a_confirmed")) and bool(s.get("b_confirmed")):
        var tx:=get_tree().get_first_node_in_group("trade_transaction_service") as BrambleTradeTransactionService
        if tx==null:return _reject("trade_service_unavailable")
        var result:=tx.exchange(trade_id,int(s.a_peer),int(s.b_peer),s.a_offer,s.b_offer)
        s["status"]="committed" if bool(result.get("ok",false)) else "failed";s["result"]=result;sessions[trade_id]=s
    trade_session_changed.emit(trade_id,s.duplicate(true));return s.duplicate(true)
func cancel(trade_id:String,peer:int)->Dictionary:
    var s:Dictionary=sessions.get(trade_id,{});if _side(s,peer)=="":return _reject("not_participant")
    s["status"]="cancelled";sessions[trade_id]=s;trade_session_changed.emit(trade_id,s.duplicate(true));return s.duplicate(true)
func _side(s:Dictionary,peer:int)->String:
    if int(s.get("a_peer",-1))==peer:return "a"
    if int(s.get("b_peer",-1))==peer:return "b"
    return ""
func _reject(reason:String)->Dictionary:return {"ok":false,"reason":reason}
