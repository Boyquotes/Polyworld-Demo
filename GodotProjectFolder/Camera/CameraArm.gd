class_name CameraArm
extends Node3D


@export var target : Node3D
var other_target : Node3D = target

var following = true

var target_vert_position = 0.0
var other_target_vert_position = 0.0

var offset = Vector3.ZERO

var is_pov = false

var default_fov = 10
var default_distance = 85
var default_rotation = Vector3(-PI/9, 0, 0)
var default_near = 15.0

var rotation_target = default_rotation
var unfiltered_rotation = default_rotation
var last_rotation = default_rotation
var rotation_rate = 0.5
var rotation_phase = 1
var ease_curve = -2

@onready var cam = $Camera3d as Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	# 18 is half the game resolution width times the sprite pixel size (0.1)
	set_camera_properties()
	other_target = target


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	global_position = round(global_position * 200) / 200
	
	if Input.is_action_pressed("ui_up"):
		cam.position.z += 0.01
	if Input.is_action_pressed("ui_down"):
		cam.position.z -= 0.01
		


func _physics_process(_delta):

	if following && is_instance_valid(target):
		
		if !is_instance_valid(other_target):
			other_target = target
		
		var hor_position = Vector2(global_position.x, global_position.z)
		var target_hor_position = Vector2(target.global_position.x, target.global_position.z)
		var other_target_hor_position = Vector2(other_target.global_position.x, other_target.global_position.z)
		
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
		
		# change to make framerate independent
		hor_position = lerp(hor_position, (target_hor_position + other_target_hor_position)/2 + Vector2(offset.x, offset.z), 0.1)
		global_position.x = hor_position.x
		global_position.z = hor_position.y
		global_position.y = lerp(global_position.y, (target_vert_position + other_target_vert_position)/2 + offset.y, 0.1)
		
		# Clamp vertical position
		global_position.y = clamp(global_position.y, target.global_position.y - 6, target.global_position.y + 6)
		
		# Lerp camera to target rotation
		if rotation_phase < 1:
			rotation_phase = clamp(rotation_phase + rotation_rate * _delta, 0, 1)
		if !is_pov:
			rotation.x = lerp_angle(last_rotation.x, rotation_target.x, ease(rotation_phase, ease_curve))
			rotation.y = lerp_angle(last_rotation.y, rotation_target.y, ease(rotation_phase, ease_curve))
		
	else:
		pass
	
	# Pocket Camera
	var pocket_cam = get_node("PocketCamera")
	var pocket_cam_player = pocket_cam.get_node("AnimationPlayer")
	if Input.is_action_just_pressed("menu"):
		pocket_cam_player.play("Open")
	if Input.is_action_just_released("menu"):
		pocket_cam_player.play("Close")
		
		
func switch_to_pov():
	if target is Player:
		var rot = Vector3(0, -target.facing_dir_target.angle() - PI/2, 0)
		set_camera_properties(rot, -1, 60, 0.05)
		global_position = target.global_position + Vector3.UP * 0.3
		is_pov = true


func switch_to_fixed():
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