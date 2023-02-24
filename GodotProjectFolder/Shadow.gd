extends Decal


func _physics_process(delta):
	if $RayCast3D.is_colliding():
		visible = true
		size.y = (global_transform.origin.y - $RayCast3D.get_collision_point().y) * 2 + 0.4
	else:
		visible = false
