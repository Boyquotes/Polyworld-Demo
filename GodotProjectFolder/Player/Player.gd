class_name Player
extends CharacterBody3D


const RUN_SPEED := 12.0 #12
const RUN_ACCEL := 60.0 # 60
const RUN_DECEL := 50.0 # 50
const AIR_ACCEL := 30.0
const TURN_SPEED := 15.0
const JUMP_VELOCITY := 15.0
const GRAVITY := 70.0
const HOLD_GRAVITY := 30.0
const JUMP_BUFFER := 0.075
const COYOTE_TIME := 0.075

var input_dir := Vector2.ZERO
var relative_input_dir := Vector2.ZERO
var facing_dir := Vector2.DOWN
var target_facing_dir := Vector2.DOWN

var can_hold_jump = false

@onready var cam = get_viewport().get_camera_3d() 
@onready var anim = $Model/AnimationPlayer as AnimationPlayer
@onready var s_player = $AudioStreamPlayer3D as AudioStreamPlayer3D

var right_cooldown = 0.5
var left_cooldown = 1

var is_right_cooling = false
var is_left_cooling = false

func _ready():
	pass


func _process(delta):
	
	# Get the input direction
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	# Get the input direction relative to the camera
	relative_input_dir = input_dir.rotated(-cam.global_rotation.y).normalized()
	
	# Set the rotation
	facing_dir = facing_dir.slerp(target_facing_dir, TURN_SPEED * delta)
	rotation.y = -facing_dir.angle() + PI/2


func _physics_process(delta):
	if Input.is_action_just_pressed("interact"):
		var interact_box = get_node("InteractBox") as Area3D
		var overlapping_bodies = interact_box.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body == self:
				break
			if body.has_method("interact"):
				body.interact()


func set_target_facing(dir:Vector2):
	target_facing_dir = dir.normalized()
