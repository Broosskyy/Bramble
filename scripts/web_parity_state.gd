class_name BrambleWebParityState
extends Node

signal profile_changed(profile:Dictionary)
const SAVE_PATH:="user://bramble_v10_web_parity_profile.json"
var profile:Dictionary={}
var cooldowns:Dictionary={}
var momentum:=0.0
var flow_left:=0.0
var combo:=0
var combo_left:=0.0

func _ready()->void:
    add_to_group("web_parity_state")
    profile=_fresh_profile()
    _load()

func _process(delta:float)->void:
    for key in cooldowns.keys():cooldowns[key]=maxf(0.0,float(cooldowns[key])-delta)
    flow_left=maxf(0.0,flow_left-delta)
    combo_left=maxf(0.0,combo_left-delta)
    if combo_left<=0.0:combo=0
    if flow_left<=0.0 and momentum>0.0:momentum=maxf(0.0,momentum-delta*2.0)

func _fresh_profile()->Dictionary:
    return {
        "name":"Adventurer","lv":1,"xp":0,"job":1,"jxp":0,"class_id":"adventurer",
        "gold":0,"reputation":0,"hp":100,"max_hp":100,"stats":{"str":1,"dex":1,"int":1,"vit":1},
        "skill_points":0,"inventory":[{"id":"starter_sword","qty":1,"rarity":"common","enhance":0},{"id":"potion","qty":5,"rarity":"common","enhance":0}],
        "equipment":{"weapon":"starter_sword","armor":"","boots":"","charm":""},"upgrade":{"weapon":0,"armor":0,"boots":0,"charm":0},
        "quest_index":0,"counters":{"slimeKills":0,"meadowKills":0,"forestKills":0,"marshKills":0,"mineKills":0,"caveKills":0,"herbs":0,"bossKills":0},
        "pets":[],"active_pet":"","pet_progress":{},"specialists":[],"active_specialist":"",
        "event":{"pumpkins":0,"runs":0,"bossWins":0},"raids":{"runs":0,"wins":0,"bestTime":0},"instant":{"runs":0,"wins":0,"bestWave":0},
        "loot_pity":0,"kills":0,"boss_kills":0,"map":"village"
    }

func _load()->void:
    if not FileAccess.file_exists(SAVE_PATH):return
    var f:=FileAccess.open(SAVE_PATH,FileAccess.READ)
    if f:
        var v: Variant = JSON.parse_string(f.get_as_text())
        if typeof(v)==TYPE_DICTIONARY:_deep_merge(profile,v)
func save()->void:
    var f:=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if f:f.store_string(JSON.stringify(profile,"\t"))
func _deep_merge(base:Dictionary,incoming:Dictionary)->void:
    for k in incoming.keys():
        if typeof(base.get(k))==TYPE_DICTIONARY and typeof(incoming[k])==TYPE_DICTIONARY:_deep_merge(base[k],incoming[k])
        else:base[k]=incoming[k]
func emit_changed()->void:profile_changed.emit(profile);save()
func register_hit(amount:=2.2)->void:
    momentum=minf(100.0,momentum+amount)
    if momentum>=100.0 and flow_left<=0.0:flow_left=6.0
func register_kill(enemy_id:String,map_id:String)->void:
    profile["kills"]=int(profile.get("kills",0))+1
    profile["loot_pity"]=int(profile.get("loot_pity",0))+1
    var c:Dictionary=profile.get("counters",{})
    if enemy_id in ["slime","monster_sprout"]:c["slimeKills"]=int(c.get("slimeKills",0))+1
    var map_counter: String = String({"meadow":"meadowKills","forest":"forestKills","marsh":"marshKills","mine":"mineKills","cave":"caveKills"}.get(map_id,""))
    if map_counter!="":c[map_counter]=int(c.get(map_counter,0))+1
    profile["counters"]=c
    emit_changed()
