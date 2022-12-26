class_name HealthBar
extends ProgressBar


var health : int:
	set(val):
		$DifferenceBar.value = value
		value = val
		#maybe the diff_time is dependent on how long the enemy is stunned? that way it shows total combo damage
		diff_time = 100
		
var diff_time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	$DifferenceBar.max_value = max_value
	
	diff_time -= 1
	if diff_time <= 0:
		diff_time = 0
		$DifferenceBar.value = lerp($DifferenceBar.value, value, 0.1)
	
	# Position the health bar
	position = get_viewport().get_camera_3d().unproject_position(get_parent().global_position)
	position -= size/2
	position.y -= 30


func _physics_process(delta):
	pass
