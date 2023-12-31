class_name CameraArm
extends Node3D


@export var target : Node3D
var other_target : Node3D

var following = true

var target_hor_position = Vector2.ZERO
var target_vert_position = 0.0
var other_target_hor_position = Vector2.ZERO
var other_target_vert_position = 0.0

var offset = Vector3.ZERO

var is_pov = false

var default_fov = 11
var default_distance = 70
var default_rotation = Vector3(-PI/8, 0, 0)
var default_near = 30.0

var rotation_target = default_rotation
var unfiltered_rotation = default_rotation
var last_rotation = default_rotation
var rotation_rate = 0.5
var rotation_phase = 1
var ease_curve = -2

var shake_amt = 0

@onready var cam = $Camera3d as Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	# 18 is half the game resolution width times the sprite pixel size (0.1)
	set_camera_properties()
	other_target = target


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Camera shake
	cam.h_offset = snappedf(shake_amt * (randf() * 2 - 1), 0.01)
	cam.v_offset = snappedf(shake_amt * (randf() * 2 - 1), 0.01)
	shake_amt = clamp(shake_amt * 0.9, 0, 1)
	
	global_position = round(global_position * 200) / 200
	#global_position = global_position.snapped(Vector3(0.02, 0.02, 0.02))
	
#	if Input.is_key_pressed(KEY_UP):
#		cam.position.z -= 0.5
#	elif Input.is_key_pressed(KEY_DOWN):
#		cam.position.z += 0.5
#	elif !is_pov:
#		cam.position.z = lerp(cam.position.z, float(default_distance), 0.1)
		
	
	var look_right = Input.get_action_strength("look_right")
	var look_left = Input.get_action_strength("look_left")
	var look_up = Input.get_action_strength("look_up")
	var look_down = Input.get_action_strength("look_down")
	
	rotation_target -= Vector3(look_down - look_up, look_right - look_left, 0) * 0.01
	rotation_target.x = clamp(rotation_target.x, -PI/5, -PI/20)


func _physics_process(_delta):
	
	var hor_position = Vector2(global_position.x, global_position.z)

	if following && is_instance_valid(target):
		
		if !is_instance_valid(other_target):
			other_target = target
		
		# Set horizontal target positions
		target_hor_position = Vector2(target.global_position.x, target.global_position.z)
		other_target_hor_position = Vector2(other_target.global_position.x, other_target.global_position.z)
		
		# Set vertical target positions if they are on the ground
		if target is CharacterBody3D:
			if target.is_on_floor():
				target_vert_position = target.global_position.y
		else:
			target_vert_position = target.global_position.y
			
		if other_target is CharacterBody3D:
			if other_target.is_on_floor():
				other_target_vert_position = other_target.global_position.y
		else:
			other_target_vert_position = other_target.global_position.y
		
		# Clamp vertical position
		global_position.y = clamp(global_position.y, target.global_position.y - 6, target.global_position.y + 6)
	
	# TODO : make framerate independent
	# Set the position based on target values
	hor_position = lerp(hor_position, (target_hor_position + other_target_hor_position)/2 + Vector2(offset.x, offset.z), 0.1)
	global_position.x = hor_position.x
	global_position.z = hor_position.y
	global_position.y = lerp(global_position.y, (target_vert_position + other_target_vert_position)/2 + offset.y, 0.1) + 0.2
	
	# Lerp camera to target rotation
	if rotation_phase < 1:
		rotation_phase = clamp(rotation_phase + rotation_rate * _delta, 0, 1)
	if !is_pov:
		rotation.x = lerp_angle(last_rotation.x, rotation_target.x, ease(rotation_phase, ease_curve))
		rotation.y = lerp_angle(last_rotation.y, rotation_target.y, ease(rotation_phase, ease_curve))
	
	# Pocket Camera
	var pocket_cam = get_node("PocketCamera")
	var pocket_cam_player = pocket_cam.get_node("AnimationPlayer")
	if Input.is_action_just_pressed("pocket_cam"):
		pocket_cam_player.play("Open")
	if Input.is_action_just_released("pocket_cam"):
		pocket_cam_player.play("Close")
		
		
func switch_to_pov():
	if target is Player:
		var rot = Vector3(0, -target.facing_dir_target.angle() - PI/2, 0)
		set_camera_properties(rot, -1, 60, 0.05)
		global_position = target.global_position + Vector3.UP * 0.3
		is_pov = true


func switch_to_fixed():
	if is_pov:
		target.facing_dir_target = Vector2(-sin(rotation.y), -cos(rotation.y))
		set_camera_properties()
		is_pov = false


func set_camera_properties(rot = rotation_target, dist = default_distance, fov = default_fov, near = default_near):
	rotation = rot
	cam.position.z = dist
	cam.fov = fov
	cam.near = near


func set_rotation_target(rot = default_rotation):
	rotation_phase = 0
	last_rotation = rotation
	rotation_target = rot
