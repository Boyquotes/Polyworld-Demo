class_name Shaker
extends Timer


var active = true
var amplitude : float
var duration = -1

@onready var target = get_parent()
@onready var center_position = target.position
@onready var target_position = center_position


func _ready():
	for child in target.get_children():
		if child != self && child is Shaker:
			center_position = child.center_position
			child.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		if duration != -1:
			duration -= 1
			if duration <= 0:
				end_shake()
		target.position = target.position.lerp(target_position, 0.5)


func initialize(amp : float, rate : float, dur = -1):
	amplitude = amp
	wait_time = rate
	duration = dur
	


func end_shake():
	target.position = center_position
	active = false
	if not is_queued_for_deletion():
		queue_free()
	


func _on_timeout():
	var rand_direction = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	target_position = center_position + rand_direction * amplitude * 0.5
	

