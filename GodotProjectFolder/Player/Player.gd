class_name Player
extends CharacterBody3D


const RUN_SPEED := 12.0 #12
const RUN_ACCEL := 60.0 # 60
const RUN_DECEL := 50.0 # 50
const AIR_ACCEL := 25.0
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

var aim_target : Node3D
var aim_direction : Vector3

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
	
	aim_target = auto_aim_target()
	if aim_target:
		aim_direction = global_position.direction_to(aim_target.global_position)
		get_parent().get_node("Sprite3D").global_position = lerp(get_parent().get_node("Sprite3D").global_position, aim_target.global_position, 0.2)
		get_parent().get_node("Sprite3D").visible = true
	else:
		aim_direction = Vector3(target_facing_dir.x, 0, target_facing_dir.y)
		get_parent().get_node("Sprite3D").visible = false
	


func _physics_process(delta):
	
	# Handle interaction
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


func auto_aim_target(aim_ahead = 0):
	var dist = 20
	var target_node = null
	var target_angle = Vector3(facing_dir.x, 0, facing_dir.y).normalized()
	for n in get_tree().get_nodes_in_group("hurtboxes"): #change this to hurtbox
		if n != $Hurtbox:
			var ppos = global_position
			var ppos2d = Vector2(ppos.x, ppos.z)
			var npos = n.global_position
			var npos2d = Vector2(npos.x, npos.z)
			
			var param := PhysicsRayQueryParameters3D.new()
			param.from = ppos
			param.to = npos
			param.collision_mask = 0b0001 #Bit mask for the first layer
			var space_state = get_world_3d().direct_space_state
			var result := space_state.intersect_ray(param)
			
			var angle_difference = abs(ppos2d.direction_to(npos2d).angle_to(target_facing_dir.normalized()))
			
			if result:
				# collision at ray point
				pass
			else:
				if angle_difference < PI/3 or (angle_difference < PI/1.5 and n == aim_target): # change to else to just target nearest enemy
				#else:
					var current_dist = ppos.distance_to(npos)
					if current_dist < dist:
						dist = current_dist
						target_node = n
						var nvel = Vector3.ZERO
						if "velocity" in n:
							nvel = n.velocity
						target_angle = ppos.direction_to(npos + nvel * aim_ahead)
			
	
	return target_node
