class_name BrambleCharacterService
extends Node
const MAX_CHARACTERS_PER_ACCOUNT:=4
func _ready()->void:add_to_group("character_service")
func list_characters(account_id:String)->Array:
    var repo:=get_tree().get_first_node_in_group("character_repository") as BrambleCharacterRepository;var out:Array=[]
    if repo:
        for s in repo.list_for_account(account_id):out.append(_summary(s))
    return out
func create_character(account_id:String,request:Dictionary,seed:Dictionary)->Dictionary:
    var repo:=get_tree().get_first_node_in_group("character_repository") as BrambleCharacterRepository
    if repo==null or repo.count_for_account(account_id)>=MAX_CHARACTERS_PER_ACCOUNT:return {}
    var ids:=get_tree().get_first_node_in_group("identity_service") as BrambleIdentityService
    var state:=seed.duplicate(true);state["account_id"]=account_id;state["character_id"]=ids.new_id("chr") if ids else "chr_%x"%randi();state["created_at"]=Time.get_unix_time_from_system()
    state["name"]=_safe_name(String(request.get("name","Adventurer")));state["class_id"]=String(request.get("class_id",state.get("class_id","adventurer")))
    repo.save_character(state);repo.flush();return state
func delete_character(account_id:String,character_id:String)->bool:
    var repo:=get_tree().get_first_node_in_group("character_repository") as BrambleCharacterRepository
    if repo==null:return false
    var state:=repo.get_character(character_id)
    if state.is_empty() or String(state.get("account_id",""))!=account_id:return false
    return repo.delete_character(character_id)
func select_character(account_id:String,character_id:String)->Dictionary:
    var repo:=get_tree().get_first_node_in_group("character_repository") as BrambleCharacterRepository
    if repo==null:return {}
    var s:=repo.get_character(character_id);return s if String(s.get("account_id",""))==account_id else {}
func resolve(account_id:String,claim:Dictionary,seed:Dictionary)->Dictionary:
    var requested:=String(claim.get("character_id",""));var state:=select_character(account_id,requested) if requested!="" else {}
    if state.is_empty():
        var repo:=get_tree().get_first_node_in_group("character_repository") as BrambleCharacterRepository
        if repo:state=repo.find_for_account(account_id)
    if state.is_empty():state=create_character(account_id,{"name":"Adventurer"},seed)
    return state
func persist(state:Dictionary)->void:
    var repo:=get_tree().get_first_node_in_group("character_repository") as BrambleCharacterRepository
    if repo:repo.save_character(state)
func _summary(s:Dictionary)->Dictionary:return {"character_id":s.get("character_id",""),"name":s.get("name","Adventurer"),"class_id":s.get("class_id","adventurer"),"level":s.get("level",1),"map":s.get("map","village")}
func _safe_name(v:String)->String:
    var n:=v.strip_edges();if n.length()<2:n="Adventurer"
    return n.substr(0,20)
