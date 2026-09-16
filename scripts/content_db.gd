class_name BrambleContentDB
extends Node

var classes:Dictionary={}
var skills:Dictionary={}
var items:Dictionary={}
var quests:Array=[]
var enemies:Dictionary={}
var maps:Dictionary={}
var npcs:Dictionary={}
var portals:Array=[]
var network_protocol:Dictionary={}
var registry:Dictionary={}

func _ready()->void:
    add_to_group("content_db")
    classes=_load_dict("classes.json")
    skills=_load_dict("skills.json")
    items=_load_dict("items.json")
    quests=_load_array("quests.json")
    enemies=_load_dict("enemies.json")
    maps=_load_dict("maps.json")
    npcs=_load_dict("npcs.json")
    portals=_load_array("portals.json")
    network_protocol=_load_dict("network_protocol.json")
    registry=_load_dict("bramble_content_registry.json")

func _load_json(name:String)->Variant:
    var f:=FileAccess.open("res://data/content/"+name,FileAccess.READ)
    if f==null:return null
    return JSON.parse_string(f.get_as_text())
func _load_dict(name:String)->Dictionary:
    var v: Variant = _load_json(name); return v if typeof(v)==TYPE_DICTIONARY else {}
func _load_array(name:String)->Array:
    var v: Variant = _load_json(name); return v if typeof(v)==TYPE_ARRAY else []
func class_data(id:String)->Dictionary:return classes.get(id,{})
func class_skills(id:String)->Array:return skills.get(id,[])
func item_data(id:String)->Dictionary:return items.get(id,{})
func enemy_data(id:String)->Dictionary:return enemies.get(id,{})
func map_data(id:String)->Dictionary:return maps.get(id,{})
func quest_data(index:int)->Dictionary:
    if index<0 or index>=quests.size():return {}
    return quests[index]
