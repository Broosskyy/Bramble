class_name BrambleCharacterRepository
extends Node
signal character_saved(character_id:String)
const SAVE_PATH:="user://bramble_v11_characters.json"
var records:Dictionary={}
var dirty:Dictionary={}
var autosave_elapsed:=0.0

func _ready()->void:
    add_to_group("character_repository")
    _load_store()

func _process(delta:float)->void:
    autosave_elapsed+=delta
    if autosave_elapsed>=15.0:
        autosave_elapsed=0.0
        flush()

func get_character(character_id:String)->Dictionary:
    return records.get(character_id,{}).duplicate(true)

func find_for_account(account_id:String)->Dictionary:
    var all:=list_for_account(account_id)
    return all[0] if not all.is_empty() else {}

func list_for_account(account_id:String)->Array:
    var out:Array=[]
    for value in records.values():
        if String(value.get("account_id",""))==account_id:out.append(value.duplicate(true))
    out.sort_custom(func(a,b):return float(a.get("created_at",0))<float(b.get("created_at",0)))
    return out

func count_for_account(account_id:String)->int:return list_for_account(account_id).size()

func delete_character(character_id:String)->bool:
    if not records.has(character_id):return false
    records.erase(character_id);dirty[character_id]=true;flush();return true

func save_character(state:Dictionary)->void:
    var character_id:=String(state.get("character_id",""))
    if character_id=="": return
    var persistent:=state.duplicate(true)
    persistent.erase("peer_id");persistent.erase("connected");persistent.erase("disconnect_time");persistent.erase("session_id")
    records[character_id]=persistent;dirty[character_id]=true

func flush()->void:
    if dirty.is_empty(): return
    var f:=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(records,"  "))
        for id in dirty.keys(): character_saved.emit(String(id))
        dirty.clear()

func _load_store()->void:
    if not FileAccess.file_exists(SAVE_PATH): return
    var f:=FileAccess.open(SAVE_PATH,FileAccess.READ)
    if f==null:return
    var parsed=JSON.parse_string(f.get_as_text())
    if parsed is Dictionary: records=parsed
