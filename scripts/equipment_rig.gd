class_name BrambleEquipmentRig
extends Node2D
@onready var torso:Sprite2D=$Torso
@onready var head:Sprite2D=$Head
@onready var lower:Sprite2D=$Lower
@onready var weapon:Sprite2D=$Weapon
var registry:Dictionary={}

func _ready()->void:
	var f:=FileAccess.open("res://data/equipment_registry_v4.json",FileAccess.READ)
	if f:
		var v:Variant=JSON.parse_string(f.get_as_text())
		if typeof(v)==TYPE_DICTIONARY: registry=v

func set_equipment(style:String,has_armor:bool,has_boots:bool,weapon_id:String)->void:
	torso.visible=has_armor;head.visible=has_armor;lower.visible=has_boots;weapon.visible=weapon_id!=""
	if has_armor:
		torso.texture=load("res://assets/equipment/armor/%s_torso.png"%style)
		head.texture=load("res://assets/equipment/armor/%s_head.png"%style)
	if has_boots: lower.texture=load("res://assets/equipment/armor/%s_boots_and_gloves.png"%style)
	if weapon_id!="": weapon.texture=load("res://assets/equipment/weapons/%s.png"%weapon_id)

func set_pose(pose:String,facing_left:bool)->void:
	scale.x=-1.0 if facing_left else 1.0
	var p:Dictionary=registry.get("pose_attachments",{}).get(pose,registry.get("pose_attachments",{}).get("idle_open",{}))
	_apply(torso,p.get("torso",[0.0,0.06,0.0,0.66]),Vector2(76,78),0.66)
	_apply(head,p.get("head",[0.0,-0.31,0.0,0.42]),Vector2(62,58),0.42)
	_apply(lower,p.get("boots_and_gloves",[0.0,0.35,0.0,0.60]),Vector2(72,55),0.60)
	_apply(weapon,p.get("weapon",[0.27,0.47,-26.0,0.42]),Vector2(44,74),0.42)

func _apply(s:Sprite2D,d:Array,base:Vector2,k0:float)->void:
	if s==null:return
	s.position=Vector2(float(d[0])*84.0,float(d[1])*112.0)
	s.rotation_degrees=float(d[2])
	var k:=float(d[3])/k0
	s.scale=Vector2(k,k)
