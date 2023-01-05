class_name HealthBar
extends ProgressBar


var health : int:
	set(val):
		value = val
		diff_time = 100

var max_health : int:
	set(val):
		max_value = val
		$DifferenceBar.max_value = val

var diff_time = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	diff_time -= 1
	if diff_time <= 0:
		diff_time = 0
		$DifferenceBar.value = lerp($DifferenceBar.value, value, 0.1)
	
	# Position the health bar
	position = get_viewport().get_camera_3d().unproject_position(get_parent().global_position)
	position -= size/2
	position.y -= 30
