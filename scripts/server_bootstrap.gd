class_name BrambleServerBootstrap
extends Node

func _ready()->void:
    add_to_group("server_bootstrap")
    var args:=OS.get_cmdline_args()
    var dedicated:="--bramble-server" in args or DisplayServer.get_name()=="headless"
    var port:=27840
    var relay:=""
    for arg in args:
        if arg.begins_with("--port="):
            port=int(arg.trim_prefix("--port="))
        elif arg.begins_with("--relay="):
            relay=arg.trim_prefix("--relay=")
    if dedicated:
        var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
        if net:
            net.host(port)
        print("BRAMBLE V11 dedicated authority UDP %d"%port)
        if relay!="":
            print("Relay adapter configured: "+relay)
