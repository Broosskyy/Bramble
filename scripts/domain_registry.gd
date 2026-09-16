class_name BrambleDomainRegistry
extends Node
const DOMAINS:=["identity","session","character","world","combat","skills","npc","inventory","equipment","progression","loot","quest","party","social","liveops","economy","shop","trade"]
func _ready()->void:
    add_to_group("domain_registry")
    print("BRAMBLE V11 domains: "+", ".join(DOMAINS))
