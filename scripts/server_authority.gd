class_name BrambleServerAuthority
extends Node

var last_action:Dictionary={}

func _ready()->void:
    add_to_group("server_authority")
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
    if net:
        net.intent_received.connect(_on_intent)
        net.peer_left.connect(_peer_left)

func _peer_left(id:int)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa:
        pa.mark_disconnected(id)

func _on_intent(peer_id:int,kind:String,p:Dictionary)->void:
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
    if net==null:
        return
    if not multiplayer.is_server() and net.mode!="host":
        return
    var lifecycle:=get_tree().get_first_node_in_group("player_lifecycle_service") as BramblePlayerLifecycleService
    if lifecycle and not lifecycle.can_gameplay(peer_id):
        return
    match kind:
        "move":
            _move(peer_id,p)
        "dash":
            _dash(peer_id,p)
        "basic_attack":
            _basic(peer_id,p)
        "skill":
            _skill(peer_id,p)
        "use_potion":
            _potion(peer_id)
        "npc_interact":
            var npc_service:=get_tree().get_first_node_in_group("npc_interaction_service") as BrambleNpcInteractionService
            if npc_service:npc_service.interact(peer_id,String(p.get("npc_id","")))
        "tame":
            var actions:=get_tree().get_first_node_in_group("online_action_authority") as BrambleOnlineActionAuthority
            if actions:
                actions.tame(peer_id,int(p.get("enemy_entity_id",0)))
        "specialist":
            var actions:=get_tree().get_first_node_in_group("online_action_authority") as BrambleOnlineActionAuthority
            if actions:
                actions.specialist(peer_id,String(p.get("specialist_id","")),bool(p.get("enable",true)))

func _move(peer_id:int,p:Dictionary)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var collision:=get_tree().get_first_node_in_group("server_collision_validator") as BrambleServerCollisionValidator
    if pa==null:
        return
    var s:=pa.ensure_peer(peer_id)
    var from:=Vector2(float(s.get("x",0.0)),float(s.get("y",360.0)))
    var dir:=Vector2(float(p.get("direction_x",0.0)),float(p.get("direction_y",0.0)))
    if dir.length()>1.0:
        dir=dir.normalized()
    var target:=from+dir*25.0
    if collision:
        target=collision.validate_motion(from,target)
    pa.update_position(peer_id,target,int(p.get("seq",0)))

func _dash(peer_id:int,p:Dictionary)->void:
    var key:="dash_%d"%peer_id
    if not _cooldown_ok(key,1.15):
        return
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var collision:=get_tree().get_first_node_in_group("server_collision_validator") as BrambleServerCollisionValidator
    if pa==null:
        return
    var s:=pa.ensure_peer(peer_id)
    var from:=Vector2(float(s.get("x",0.0)),float(s.get("y",360.0)))
    var dir:=Vector2(float(p.get("direction_x",0.0)),float(p.get("direction_y",0.0)))
    if dir.length_squared()<=0.001:
        return
    var target:=from+dir.normalized()*130.0
    if collision:
        target=collision.validate_dash(from,dir)
    pa.update_position(peer_id,target,int(p.get("seq",0)))

func _basic(peer_id:int,p:Dictionary)->void:
    var key:="atk_%d"%peer_id
    if not _cooldown_ok(key,0.44):
        return
    var validator:=get_tree().get_first_node_in_group("combat_validation_service") as BrambleCombatValidationService
    var enemy=validator.target_from_payload(peer_id,p,140.0) if validator else _nearest_enemy(peer_id,140.0)
    if enemy==null:return
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    var calc:=get_tree().get_first_node_in_group("authoritative_combat") as BrambleAuthoritativeCombat
    var damage:=13
    if pa and calc:
        damage=calc.basic_damage(pa.ensure_peer(peer_id))
    enemy.take_damage(damage)

func _skill(peer_id:int,p:Dictionary)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:return
    var s:=pa.ensure_peer(peer_id);var slot:=int(p.get("slot",0))
    var skills:=get_tree().get_first_node_in_group("skill_authority_service") as BrambleSkillAuthorityService
    if skills==null:return
    var verdict:=skills.validate_and_commit(peer_id,s,slot)
    if not bool(verdict.get("ok",false)):return
    var skill:Dictionary=verdict.get("skill",{})
    var range:=175.0
    if String(skill.get("target","")) in ["projectile","projectile_cone","ground_aoe"]:range=360.0
    if String(skill.get("role","damage"))!="damage":return
    var validator:=get_tree().get_first_node_in_group("combat_validation_service") as BrambleCombatValidationService
    var enemy=validator.target_from_payload(peer_id,p,range) if validator else _nearest_enemy(peer_id,range)
    if enemy==null:return
    var calc:=get_tree().get_first_node_in_group("authoritative_combat") as BrambleAuthoritativeCombat
    var damage:=28
    if calc:damage=calc.skill_damage(s,skill)
    enemy.take_damage(damage)
    var status:=get_tree().get_first_node_in_group("status_effect_service") as BrambleStatusEffectService
    var effect_id:=String(skill.get("status_effect",""))
    if status and effect_id!="":status.apply("enemy:%d"%enemy.get_instance_id(),effect_id,float(skill.get("status_duration",3.0)),float(skill.get("status_magnitude",1.0)),"peer:%d"%peer_id)

func _potion(peer_id:int)->void:
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:
        return
    var s:=pa.ensure_peer(peer_id)
    if float(pa.potion_cooldowns.get(peer_id,0.0))>0.0:
        return
    if int(s.get("hp",100))>=int(s.get("max_hp",100)):
        return
    var inventory:=get_tree().get_first_node_in_group("inventory_service") as BrambleInventoryService
    if inventory and inventory.remove_item(peer_id,"potion",1):
        pa.potion_cooldowns[peer_id]=8.0
        pa.heal(peer_id,int(round(int(s.get("max_hp",100))*0.34)))

func _nearest_enemy(peer_id:int,radius:float):
    var pa:=get_tree().get_first_node_in_group("player_authority") as BramblePlayerAuthority
    if pa==null:
        return null
    var s:=pa.ensure_peer(peer_id)
    var pos:=Vector2(float(s.get("x",0.0)),float(s.get("y",360.0)))
    var best=null
    var best_distance:=radius
    for node in get_tree().get_nodes_in_group("enemy"):
        if node is Node2D:
            var d:=pos.distance_to(node.global_position)
            if d<best_distance:
                best=node
                best_distance=d
    return best

func nearest_enemy_for_validation(peer_id:int,radius:float):return _nearest_enemy(peer_id,radius)

func _cooldown_ok(key:String,cd:float)->bool:
    var now:=Time.get_ticks_msec()/1000.0
    var prev:=float(last_action.get(key,-999.0))
    if now-prev<cd:
        return false
    last_action[key]=now
    return true
