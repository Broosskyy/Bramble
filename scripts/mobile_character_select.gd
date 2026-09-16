class_name BrambleMobileCharacterSelect
extends CanvasLayer
var panel:PanelContainer;var list_box:VBoxContainer;var name_edit:LineEdit
func _ready()->void:
    add_to_group("mobile_character_select");layer=90;_build();visible=false
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession
    if net:
        net.character_list_received.connect(_show_characters)
        net.character_operation_result.connect(_operation_result)
        net.world_join_received.connect(func(_s):visible=false)
func _build()->void:
    panel=PanelContainer.new();panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT,Control.PRESET_MODE_MINSIZE,24);add_child(panel)
    var root:=VBoxContainer.new();root.add_theme_constant_override("separation",14);panel.add_child(root)
    var title:=Label.new();title.text="CHARAKTER WÄHLEN";title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;root.add_child(title)
    list_box=VBoxContainer.new();list_box.size_flags_vertical=Control.SIZE_EXPAND_FILL;root.add_child(list_box)
    name_edit=LineEdit.new();name_edit.placeholder_text="Neuer Charakter";name_edit.max_length=20;root.add_child(name_edit)
    var create:=Button.new();create.text="CHARAKTER ERSTELLEN";create.custom_minimum_size.y=52;create.pressed.connect(_create);root.add_child(create)
func _show_characters(characters:Array)->void:
    visible=true
    for c in list_box.get_children():c.queue_free()
    for row in characters:
        var b:=Button.new();b.text="%s  ·  Lv. %d"%[String(row.get("name","Adventurer")),int(row.get("level",1))];b.custom_minimum_size.y=58
        var cid:=String(row.get("character_id",""));b.pressed.connect(func():_select(cid));list_box.add_child(b)
func _operation_result(operation:String,result:Dictionary)->void:
    if operation in ["create","delete"] and result.has("characters"):_show_characters(result.get("characters",[]))
func _create()->void:
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession;if net:net.create_character(name_edit.text,"adventurer","char_create_%d"%Time.get_ticks_msec());name_edit.clear()
func _select(character_id:String)->void:
    var net:=get_tree().get_first_node_in_group("network_session") as BrambleNetworkSession;if net:net.select_character(character_id)
