class_name SoftCollider
extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_push_vector():
	var overlapping_areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO
	if overlapping_areas.size() > 0:
		var target_area = overlapping_areas[0]
		var push_vector_3d = -global_position.direction_to(target_area.global_position)
		push_vector = Vector2(push_vector_3d.x, push_vector_3d.z).normalized().rotated(0.25)
	return push_vector

