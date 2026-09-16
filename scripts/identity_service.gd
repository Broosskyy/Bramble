class_name BrambleIdentityService
extends Node

func _ready()->void:
    add_to_group("identity_service")
    randomize()

func new_id(prefix:String)->String:
    return "%s_%x_%x_%x"%[prefix,Time.get_unix_time_from_system(),randi(),randi()]

func account_id_from_claim(claim:Dictionary)->String:
    var supplied:=String(claim.get("account_id",""))
    if supplied!="": return supplied
    var name:=String(claim.get("name","Player")).strip_edges().to_lower()
    return "guest_%x"%abs(name.hash())
