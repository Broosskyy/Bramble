class_name BrambleAuthoritativeCombat
extends Node
const RARITY_MULT={"common":1.0,"uncommon":1.08,"rare":1.18,"epic":1.32,"legendary":1.52}
func _ready()->void:add_to_group("authoritative_combat")
func basic_damage(s:Dictionary)->int:
    var cls:=String(s.get("class_id","adventurer"));var stats:Dictionary=s.get("stats",{});var main:="str"
    if cls=="bow":main="dex"
    elif cls=="mage":main="int"
    return maxi(1,int(round(7.0+int(s.get("level",1))*0.9+int(stats.get(main,1))*1.8+_weapon_power(s)*1.15)))
func skill_damage(s:Dictionary,skill:Dictionary)->int:
    var mult:=1.55
    if String(skill.get("target","")) in ["projectile","projectile_cone"]:mult+=0.12
    if String(skill.get("target","")) in ["melee_aoe","self_aoe","ground_aoe"]:mult+=0.20
    return maxi(1,int(round(basic_damage(s)*mult)))
func _weapon_power(s:Dictionary)->float:
    var eq:Dictionary=s.get("equipment",{});var id:=String(eq.get("weapon",""));var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if id=="" or db==null:return 0.0
    var item:=db.item_data(id);var rarity:="common";var enh:=0
    for stack in s.get("inventory",[]):
        if String(stack.get("id",""))==id:rarity=String(stack.get("rarity","common"));enh=int(stack.get("enhance",0));break
    return (float(item.get("power",0))+enh*3.0)*float(RARITY_MULT.get(rarity,1.0))
