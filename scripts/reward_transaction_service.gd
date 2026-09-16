class_name BrambleRewardTransactionService
extends Node
signal reward_committed(transaction_id:String,peer_id:int,reward:Dictionary)
signal reward_rejected(transaction_id:String,peer_id:int,reason:String)
func _ready()->void:add_to_group("reward_transaction_service")
func grant(peer_id:int,reward:Dictionary,transaction_id:String,source:String="gameplay")->Dictionary:
    if transaction_id=="":return _reject(transaction_id,peer_id,"transaction_id_required")
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return _reject(transaction_id,peer_id,"authority_unavailable")
    var economy:=get_tree().get_first_node_in_group("economy_transaction_service") as BrambleEconomyTransactionService
    if economy==null:return _reject(transaction_id,peer_id,"economy_unavailable")
    var delta={"gold":maxi(0,int(reward.get("gold",0))),"reputation":maxi(0,int(reward.get("reputation",0))),"add_items":reward.get("items",[])}
    var result:=economy.apply(peer_id,delta,transaction_id+":economy")
    if not bool(result.get("ok",false)):return _reject(transaction_id,peer_id,String(result.get("reason","economy_rejected")))
    var progression:=get_tree().get_first_node_in_group("progression_service") as BrambleProgressionService
    if progression:progression.grant(peer_id,maxi(0,int(reward.get("xp",0))),maxi(0,int(reward.get("jxp",0))),0,0)
    var state:=pa.ensure_peer(peer_id);var audit:=get_tree().get_first_node_in_group("transaction_audit_service") as BrambleTransactionAuditService
    if audit:audit.record("reward",source,state,{"transaction_id":transaction_id,"reward":reward.duplicate(true)})
    var outbox:=get_tree().get_first_node_in_group("outbox_service") as BrambleOutboxService
    if outbox:outbox.enqueue("reward.committed",{"transaction_id":transaction_id,"character_id":String(state.get("character_id","")),"source":source})
    var final={"ok":true,"transaction_id":transaction_id};reward_committed.emit(transaction_id,peer_id,reward);return final
func _reject(tid:String,peer_id:int,reason:String)->Dictionary:
    reward_rejected.emit(tid,peer_id,reason);return {"ok":false,"transaction_id":tid,"reason":reason}
