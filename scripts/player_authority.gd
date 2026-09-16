class_name BramblePlayerAuthority
extends Node
signal state_changed(peer_id:int,state:Dictionary)
const RECONNECT_GRACE:=120.0
var states:Dictionary={}
var reconnect_tokens:Dictionary={} # legacy compatibility; V11 sessions own reconnect tokens
var potion_cooldowns:Dictionary={}

func _ready()->void:
    add_to_group("player_authority")
func _process(delta:float)->void:
    for id in potion_cooldowns.keys():potion_cooldowns[id]=maxf(0.0,float(potion_cooldowns[id])-delta)
    var now:=Time.get_unix_time_from_system()
    for id in states.keys().duplicate():
        var s:Dictionary=states[id]
        if not bool(s.get("connected",true)) and now-float(s.get("disconnect_time",now))>RECONNECT_GRACE:states.erase(id)
    for token in reconnect_tokens.keys().duplicate():
        if not states.has(int(reconnect_tokens[token])):reconnect_tokens.erase(token)
func ensure_peer(peer_id:int,seed:Dictionary={})->Dictionary:
    if states.has(peer_id):return states[peer_id]
    var s={"peer_id":peer_id,"x":BrambleWorldPresentationConfig.PLAYER_SPAWN.x,"y":BrambleWorldPresentationConfig.PLAYER_SPAWN.y,"hp":100,"max_hp":100,"level":1,"job":1,"class_id":"adventurer","gold":0,"xp":0,"jxp":0,"reputation":0,
        "stats":{"str":1,"dex":1,"int":1,"vit":1},"inventory":[],"equipment":{"weapon":"starter_sword"},"upgrade":{},"quest_index":0,"counters":{},"loot_pity":0,"kills":0,
        "event":{"pumpkins":0,"runs":0,"bossWins":0},"raids":{"runs":0,"wins":0,"bestTime":0},"instant":{"runs":0,"wins":0,"bestWave":0},"pets":[],"active_pet":"","specialists":[],"active_specialist":"","map":"village","connected":true,"last_processed_seq":0}
    for k in seed.keys():s[k]=seed[k]
    states[peer_id]=s;potion_cooldowns[peer_id]=0.0;return s
func update_position(peer_id:int,pos:Vector2,seq:int)->void:
    var s: Dictionary = ensure_peer(peer_id);s["x"]=pos.x;s["y"]=pos.y;s["last_processed_seq"]=maxi(int(s.get("last_processed_seq",0)),seq);state_changed.emit(peer_id,s)
func damage(peer_id:int,amount:int)->void:
    var s: Dictionary = ensure_peer(peer_id);s["hp"]=maxi(0,int(s.get("hp",100))-amount)
    if int(s["hp"])<=0:s["hp"]=int(s.get("max_hp",100));s["x"]=BrambleWorldPresentationConfig.PLAYER_SPAWN.x;s["y"]=BrambleWorldPresentationConfig.PLAYER_SPAWN.y;s["map"]="village"
    state_changed.emit(peer_id,s)
func heal(peer_id:int,amount:int)->void:
    var s: Dictionary = ensure_peer(peer_id);s["hp"]=mini(int(s.get("max_hp",100)),int(s.get("hp",100))+amount);state_changed.emit(peer_id,s)
func grant_reward(peer_id:int,reward:Dictionary)->void:
    var rewards:=get_tree().get_first_node_in_group("reward_transaction_service") as BrambleRewardTransactionService
    var tid:="reward_%d_%d_%d"%[peer_id,Time.get_ticks_msec(),randi()]
    if rewards:rewards.grant(peer_id,reward,tid,"player_authority")

func mark_disconnected(peer_id:int)->void:
    if states.has(peer_id):
        states[peer_id]["connected"]=false;states[peer_id]["disconnect_time"]=Time.get_unix_time_from_system()
        var characters:=get_tree().get_first_node_in_group("character_service") as BrambleCharacterService
        if characters:characters.persist(states[peer_id])
    var sessions:=get_tree().get_first_node_in_group("session_service") as BrambleSessionService
    if sessions:sessions.mark_disconnected(peer_id)
    var lifecycle:=get_tree().get_first_node_in_group("player_lifecycle_service") as BramblePlayerLifecycleService
    if lifecycle:lifecycle.disconnected(peer_id)
func issue_token(peer_id:int)->String:
    var token:="%08x%08x%08x"%[randi(),randi(),randi()];reconnect_tokens[token]=peer_id;return token
func snapshot()->Array:
    var arr:Array=[]
    for id in states.keys():arr.append(states[id].duplicate(true))
    return arr

func snapshot_lite()->Array:
    var arr:Array=[]
    for id in states.keys():
        var s:Dictionary=states[id]
        arr.append({
            "peer_id": id,
            "x": float(s.get("x", 0.0)),
            "y": float(s.get("y", 360.0)),
            "dir_x": float(s.get("dir_x", 0.0)),
            "connected": bool(s.get("connected", true)),
            "hp": int(s.get("hp", 100)),
            "max_hp": int(s.get("max_hp", 100)),
            "level": int(s.get("level", 1)),
        })
    return arr
