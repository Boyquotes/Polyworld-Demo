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
	pass


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
	
	if Input.is_action_pressed("menu"):
		if Input.is_action_just_pressed("menu"):
			get_node("Camera3d").position.z = -1
			if target is Player:
				rotation.y = -target.target_facing_dir.angle() - PI / 2
				rotation.x = 0
				get_node("Camera3d").fov = 40
				get_tree().root.get_node("Main/UILayer/Binoculars/AnimationPlayer").play("Open")
		
		if Input.is_action_pressed("ui_right"):
			rotate_y(-0.02)
		if Input.is_action_pressed("ui_left"):
			rotate_y(0.02)
		if Input.is_action_pressed("ui_down"):
			rotation.x -= 0.02
		if Input.is_action_pressed("ui_up"):
			rotation.x += 0.02
		target.target_facing_dir = Vector2(-sin(rotation.y), -cos(rotation.y))
		global_position = target.global_position + target_offset + Vector3.UP * 0.3
		
	else:
		if Input.is_action_just_released("menu"):
			get_node("Camera3d").position.z = 50
			rotation.y = 0
			rotation.x = -0.35
			get_node("Camera3d").fov = 20
			get_tree().root.get_node("Main/UILayer/Binoculars/AnimationPlayer").play("Close")
			
		if Input.is_action_pressed("ui_right"):
			rotate_y(0.02)
		if Input.is_action_pressed("ui_left"):
			rotate_y(-0.02)
		
		
