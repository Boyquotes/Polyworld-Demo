extends Node3D


func _physics_process(_delta):
	if $RayCast3D.is_colliding():
		visible = true
		$Decal.size.y = (global_transform.origin.y - $RayCast3D.get_collision_point().y) + 0.6
		$Decal.position.y = -($Decal.size.y / 2)
	else:
		visible = false
