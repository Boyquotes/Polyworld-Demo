class_name Player
extends Entity


const JUMP_BUFFER := 0.075
const COYOTE_TIME := 0.075

@export var climb_speed = 5.0

var input_dir := Vector2.ZERO
var relative_input_dir := Vector2.ZERO

var can_hold_jump = false

var aim_target : Node3D
var aim_direction : Vector3

@onready var cam = get_viewport().get_camera_3d() 
@onready var anim = $Model/AnimationPlayer as AnimationPlayer
@onready var s_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
@onready var aim_icon = get_parent().get_node("AimIcon") as Node3D

var right_cooldown = 0.5
var left_cooldown = 1

var is_right_cooling = false
var is_left_cooling = false

var partner_activation_position = Vector3.ZERO
var partner_activation_time = 0.0


func _ready():
	pass


func _process(delta):
	
	var partner = get_parent().get_node("Partner")
	if Input.is_action_pressed("special"):
		partner.is_being_called = true
		if Input.is_action_just_pressed("special"):
			partner_activation_time = 0.0
			partner_activation_position = partner.global_position
		partner_activation_time += 0.025
		if partner_activation_time >= 0.5:
			partner_activation_time = 1.0
			get_node("StateMachine").transition_to("Partner")
		partner.global_position = partner.global_position.lerp(global_position, partner_activation_time)
		partner.rotation.y = rotation.y
	else:
		partner.is_being_called = false
		partner_activation_time = 0.0
	
	# Get the input direction
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	# Get the input direction relative to the camera
	relative_input_dir = input_dir.rotated(-cam.global_rotation.y).normalized()
	
	# Handle interaction
	if Input.is_action_just_pressed("interact"):
		var interact_box = get_node("InteractBox") as Area3D
		var overlapping_bodies = interact_box.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body == self:
				break
			if body.has_method("interact"):
				body.interact()
	
	# Update aim
	aim_target = auto_aim_target()
	if aim_target:
		aim_direction = global_position.direction_to(aim_target.global_position)
		aim_icon.global_position = lerp(aim_icon.global_position, aim_target.global_position, 0.2)
		aim_icon.visible = true
	else:
		aim_direction = Vector3(facing_dir_target.x, 0, facing_dir_target.y)
		aim_icon.visible = false
	
	update_facing(delta)


func _physics_process(delta):
	
	# Push rigidbodies out of the way
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_central_impulse(-col.get_normal() * 3)


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
			
			var angle_difference = abs(ppos2d.direction_to(npos2d).angle_to(facing_dir_target.normalized()))
			
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
