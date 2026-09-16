class_name BramblePredictionReconciliation
extends Node
var pending:Array=[]
const SOFT:=42.0
const HARD:=220.0
func _ready()->void:add_to_group("prediction_reconciliation")
func record_input(seq:int,kind:String,payload:Dictionary)->void:
    pending.append({"seq":seq,"kind":kind,"payload":payload.duplicate(true)})
    while pending.size()>60:pending.pop_front()
func reconcile(server:Dictionary)->void:
    var ack:=int(server.get("last_processed_seq",0));pending=pending.filter(func(e):return int(e.get("seq",0))>ack)
    var player:=get_tree().get_first_node_in_group("player") as CharacterBody2D
    if player==null:return
    var corrected:=Vector2(float(server.get("x",player.global_position.x)),float(server.get("y",player.global_position.y)))
    for e in pending:
        var p:Dictionary=e.get("payload",{});var d:=Vector2(float(p.get("direction_x",0)),float(p.get("direction_y",0)))
        if d.length()>1.0:d=d.normalized()
        if String(e.get("kind",""))=="move":corrected+=d*25.0
        elif String(e.get("kind",""))=="dash":corrected+=d*130.0
    var dist:=player.global_position.distance_to(corrected)
    if dist>=HARD:player.global_position=corrected
    elif dist>=SOFT:player.global_position=player.global_position.lerp(corrected,0.36)
