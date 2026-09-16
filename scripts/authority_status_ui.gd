class_name BrambleAuthorityStatusUI
extends Label
func _ready()->void:add_to_group("authority_status_ui");text="OFFLINE";position=Vector2(1030,18);add_theme_font_size_override("font_size",12)
func _process(_delta:float)->void:
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
    if net==null:text="OFFLINE"
    elif net.mode=="host":text="HOST AUTHORITY"
    elif net.mode=="client":text="CLIENT SYNC"
    else:text="OFFLINE"
