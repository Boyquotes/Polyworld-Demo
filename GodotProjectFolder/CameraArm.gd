class_name CameraArm
extends Node3D


@export var target : Node3D
var target_offset := Vector3.ZERO

var following = true
var target_y = 0.0

var default_fov = 10
var default_distance = 85
var default_rotation = Vector3(-PI/9, 0, 0)
var default_near = 15

@onready var cam = $Camera3d as Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	# 18 is half the game resolution width times the sprite pixel size (0.1)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = round(global_position*200)/200


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
	
	var gumsoft_cam = get_parent().get_node("Interface/Binoculars")
	var gumsoft_cam_player = get_parent().get_node("Interface/Binoculars/AnimationPlayer")
	if Input.is_action_pressed("menu"):
		if Input.is_action_just_pressed("menu"):
			gumsoft_cam_player.play("Open")
		
		if Input.is_action_pressed("ui_right"):
			rotate_y(-0.02)
		if Input.is_action_pressed("ui_left"):
			rotate_y(0.02)
		if Input.is_action_pressed("ui_down"):
			rotation.x -= 0.02
		if Input.is_action_pressed("ui_up"):
			rotation.x += 0.02
		
	else:
		if Input.is_action_just_released("menu"):
			
			gumsoft_cam_player.play("Close")
			
		if Input.is_action_pressed("ui_right"):
			rotate_y(0.02)
		if Input.is_action_pressed("ui_left"):
			rotate_y(-0.02)
		6
		
func switch_to_pov():
	# change to use set_camera_properties()
	cam.position.z = -1
	if target is Entity:
		rotation.y = -target.facing_dir_target.angle() - PI / 2
		rotation.x = 0
		cam.fov = 60
		cam.near = 0.05
	
	global_position = target.global_position + target_offset + Vector3.UP * 0.3


func switch_to_fixed():
	target.facing_dir_target = Vector2(-sin(rotation.y), -cos(rotation.y))
	set_camera_properties()


func set_camera_properties(rot = default_rotation, dist = default_distance, fov = default_fov, near = default_near):
	rotation = default_rotation
	cam.position.z = dist
	cam.fov = fov
	cam.near = near
