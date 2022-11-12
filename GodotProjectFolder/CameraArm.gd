extends Node3D


@export var target : Node3D
var target_offset := Vector3.ZERO

var following = true
var target_y = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		rotate_y(0.01)
	if Input.is_action_pressed("ui_left"):
		rotate_y(-0.01)


func _physics_process(delta):

	if following:
		global_position.x = lerp(global_position.x, target.global_position.x + target_offset.x, 0.1)
		global_position.z = lerp(global_position.z, target.global_position.z + target_offset.z, 0.1)
		
		if target is CharacterBody3D:
			if target.is_on_floor():
				target_y = target.global_position.y
				
			global_position.y = lerp(global_position.y, target_y + target_offset.y, 0.1)
			
		else:
			global_position.y = target.global_position.y + target_offset.y
	else:
		pass
