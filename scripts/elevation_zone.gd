class_name BrambleElevationZone
extends Area2D

@export var height_level := 1
@export var zone_name := "h1"

func _ready() -> void:
	add_to_group("elevation_zone")
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var svc := get_tree().get_first_node_in_group("elevation_service") as BrambleElevationService
		if svc:
			svc.set_player_height(body, height_level, zone_name)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		var svc := get_tree().get_first_node_in_group("elevation_service") as BrambleElevationService
		if svc:
			svc.clear_player_height(body, height_level, zone_name)
