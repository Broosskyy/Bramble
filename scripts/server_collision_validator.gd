class_name BrambleServerCollisionValidator
extends Node
const PLAYER_RADIUS:=18.0
func _ready()->void:add_to_group("server_collision_validator")
func validate_motion(from:Vector2,to:Vector2)->Vector2:
    if from.distance_to(to)>85.0:to=from+from.direction_to(to)*85.0
    var space:=get_viewport().world_2d.direct_space_state
    if space==null:return to
    var shape:=CircleShape2D.new();shape.radius=PLAYER_RADIUS
    var q:=PhysicsShapeQueryParameters2D.new();q.shape=shape;q.transform=Transform2D(0.0,to);q.collision_mask=4;q.collide_with_bodies=true;q.collide_with_areas=false
    if space.intersect_shape(q,8).is_empty():return to
    var x:=Vector2(to.x,from.y);q.transform=Transform2D(0.0,x)
    if space.intersect_shape(q,8).is_empty():return x
    var y:=Vector2(from.x,to.y);q.transform=Transform2D(0.0,y)
    if space.intersect_shape(q,8).is_empty():return y
    return from
func validate_dash(from:Vector2,dir:Vector2)->Vector2:
    if dir.length_squared()<=0.001:return from
    var safe:=from
    for i in range(1,6):
        var c:=from+dir.normalized()*130.0*(float(i)/5.0);var checked:=validate_motion(safe,c)
        if checked.distance_to(c)>2.0:return safe
        safe=checked
    return safe
