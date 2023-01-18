class_name HealthBar
extends ProgressBar


@export var is_static = false


var health : int:
	set(val):
		value = val
		diff_time = 50

var max_health : int:
	set(val):
		max_value = val
		$DifferenceBar.max_value = val

var diff_time = 0


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	diff_time -= 1
	if diff_time <= 0:
		diff_time = 0
		$DifferenceBar.value = move_toward($DifferenceBar.value, value, 1)
		
	
	# Position the health bar
	if !is_static:
		position = get_viewport().get_camera_3d().unproject_position(get_parent().global_position)
		position -= size/2
		position.y -= 30
