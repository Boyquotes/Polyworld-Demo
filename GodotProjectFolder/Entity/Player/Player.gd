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

var target_locking = false
var target_lock_range = 25

var aim_icon_mover = 0:
	set(amt):
		amt = clamp(amt, 0, 1)
		if amt == 0:
			aim_icon.visible = false
		else:
			aim_icon.visible = true
		aim_icon_mover = amt
var old_aim_icon_pos = Vector3.ZERO


@onready var cam = get_viewport().get_camera_3d() as Camera3D
@onready var anim = $Model/AnimationPlayer as AnimationPlayer
@onready var s_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
@onready var aim_icon = get_parent().get_node("AimIcon") as Node3D

@onready var target_lock_param := PhysicsRayQueryParameters3D.new()

var partner_activation_position = Vector3.ZERO
var partner_activation_time = 0.0


func _ready():
	pass


func _process(_delta):
	
	# Handle partner activation
	var partner = get_parent().get_node("Partner")
	if Input.is_action_pressed("special"):
		partner.is_being_called = true
		if Input.is_action_just_pressed("special"):
			partner_activation_time = 0.0
			partner_activation_position = partner.global_position
		partner_activation_time += _delta * 2
		if partner_activation_time >= 0.5:
			partner_activation_time = 1.0
			$StateMachine.transition_to("Partner")
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
	
	# Targeting stuff
	
	# Update aim and aim icon, store results in aim_target and aim_direction
	if Input.is_action_just_pressed("target_lock"):
		# Toggle target lock
		target_locking = !target_locking
		# If toggling target lock on, update the target
		if target_locking:
			update_aim_target(PI/2)
			aim_icon_mover = 0
	
	# If not toggling target lock on, update the target within a smaller range
	if !target_locking:
		update_aim_target(PI/5)
	
	# TODO move target lock range stuff inside the update_aim_target() method
	if is_instance_valid(aim_target) && global_position.distance_to(aim_target.global_position) < target_lock_range:
		aim_direction = global_position.direction_to(aim_target.global_position)
	else:
		target_locking = false
		aim_target = null
		aim_direction = Vector3(facing_dir_target.x, 0, facing_dir_target.y)
	
	if target_locking:
		aim_icon.global_position = lerp(global_position, aim_target.global_position, aim_icon_mover)
		aim_icon_mover += _delta * 5
		old_aim_icon_pos = aim_icon.global_position
		cam.get_parent().other_target = aim_target
	else:
		aim_icon.global_position = lerp(global_position, old_aim_icon_pos, aim_icon_mover)
		aim_icon_mover -= _delta * 5
		cam.get_parent().other_target = self
	
	# Update facing direction
	update_facing(_delta)


func _physics_process(_delta):
	# Push rigidbodies out of the way
#	for i in get_slide_collision_count():
#		var col = get_slide_collision(i)
#		if col.get_collider() is RigidBody3D:
#			col.get_collider().apply_central_impulse(-col.get_normal() * 3)
	pass


func update_aim_target(view_range):
	
	# Get the direct space state for the current world
	var space_state = get_world_3d().direct_space_state
	
	# Set physics ray query parameters
	var ppos = global_position
	var ppos2d = Vector2(ppos.x, ppos.z)
	target_lock_param.from = ppos
	target_lock_param.collision_mask = 0b0001 #Bit mask for the first layer
	
	# Initialize loop variables
	var dist = 20
	var target_node = null
	var _target_angle = Vector3(facing_dir.x, 0, facing_dir.y).normalized()
	
	# Loop through hurtboxes
	for n in get_tree().get_nodes_in_group("hurtboxes"):
		if n != $Hurtbox:
			
			# Store information for current node in loop
			var npos = n.global_position
			var npos2d = Vector2(npos.x, npos.z)
			var nangle = ppos2d.direction_to(npos2d)
			
			# Store angle difference between facing direction and current node in loop
			var angle_difference = abs(nangle.angle_to(facing_dir_target))
			
			# If the angle difference is within range
			if angle_difference < view_range:
				
				# Set physics ray query parameter
				target_lock_param.to = npos
				
				# Store ray collision information
				var result := space_state.intersect_ray(target_lock_param)
				
				if result:
					# Collision at ray point
					pass
					
				else:
					# Current node in loop is a valid target
					var current_dist = ppos.distance_to(npos)
					if current_dist < dist:
						
						# If this node is closer than the last closest node, replace the stored values
						dist = current_dist
						target_node = n
						_target_angle = ppos.direction_to(npos)
			
	aim_target = target_node
	# aim_direction = target_angle


func stun(dur = 2):
	$StateMachine/Stunned.stun_duration = dur
	$StateMachine.transition_to("Stunned")


func _on_hurtbox_area_entered(hitbox : Hitbox):
	if hitbox.caster != self:
		take_damage(hitbox.damage)


func _on_entity_died():
	die()
