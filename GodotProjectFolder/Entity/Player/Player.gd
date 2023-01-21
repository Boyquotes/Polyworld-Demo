class_name Player
extends Entity


const JUMP_BUFFER := 0.075
const COYOTE_TIME := 0.075

@export var max_mana := 40

var mana := max_mana:
	set(val):
		val = clamp(val, 0, max_mana)
		mana = val

# Input handling
var input_dir := Vector2.ZERO:
	set(vec):
		if vec == Vector2.ZERO:
			input_dir = Vector2.ZERO
			relative_input_dir = Vector2.ZERO
		else:
			input_dir = vec.normalized()
			relative_input_dir = vec.rotated(-cam.global_rotation.y).normalized()
var relative_input_dir := Vector2.ZERO
var input_enabled = true

# TODO : possibly make this an argument that can be passed thru the state machine ?
var can_hold_jump = false

# Aim and targeting
var aim_target : Node3D
var aim_direction := Vector3(facing_dir_target.x, 0, facing_dir_target.y)
var target_locking := false
var target_lock_range = 25
var target_lock_param := PhysicsRayQueryParameters3D.new()
var aim_icon_mover = 0:
	set(amt):
		amt = clamp(amt, 0, 1)
		if amt == 0:
			aim_icon.visible = false
		else:
			aim_icon.visible = true
		aim_icon_mover = amt
var old_aim_icon_pos = Vector3.ZERO

# Immunity
var is_immune := false:
	set(val):
		if val:
			$Hurtbox.set_deferred("Monitoring", false)
		else:
			$Hurtbox.set_deferred("Monitoring", true)


@onready var cam = get_viewport().get_camera_3d() as Camera3D
@onready var anim = $Model/AnimationPlayer as AnimationPlayer
@onready var s_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
@onready var aim_icon = $PositionBreak/AimIcon as Node3D

var partner_activation_position = Vector3.ZERO
var partner_activation_time = 0.0


func _ready():
	pass


func _process(_delta):
	
	# Handle UI labels
	$GoldLabel.text = "$" + str($Inventory.gold)
	$PrimaryLabel.text = $StateMachine/Primary.state_name
	$SecondaryLabel.text = $StateMachine/Secondary.state_name
	
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
	if input_enabled:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	# Handle interaction
	if Input.is_action_just_pressed("interact"):
		var interact_box = get_node("InteractRegion") as Area3D
		var overlapping_bodies = interact_box.get_overlapping_bodies()
		
		var nearest = null
		var dist = 100
		for body in overlapping_bodies:
			if body == self:
				continue
			var current_dist = body.global_position.distance_to(global_position)
			if current_dist < dist:
				dist = current_dist
				nearest = body
		if nearest:
			if nearest.has_method("interact"):
				nearest.interact()
	
	
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
	
	# Target locking stuff
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
		
		# Don't select your own hurtbox
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


# Returns true if there is enough mana, false if not
func decrease_mana(amt:=0) -> bool:
	
	# Check if there is enough mana, and if so, subtract
	if mana - amt < 0:
		return false
	
	mana -= amt
	
	# Update mana bar
	var manabar = get_node("ManaBar")
	if manabar:
		manabar.max_health = max_mana
		manabar.health = mana
	
	return true


# TODO : improve / streamline ? the way stuns are handled for entities
func stun(dur = 2):
	$StateMachine/Stunned.stun_duration = dur
	$StateMachine.transition_to("Stunned")


func _on_hurtbox_area_entered(hitbox : Hitbox):
	if hitbox.caster != self:
		if "contact" in hitbox.get_parent():
			hitbox.get_parent().contact()
			
		if hitbox.is_vessel:
			return
			
		take_damage(hitbox.damage)
		
		var impact_angle = hitbox.global_position.direction_to(global_position)
		if "direction" in hitbox.get_parent():
			impact_angle = hitbox.get_parent().direction
		velocity = Vector3(hitbox.push_force_horizontal * impact_angle.x, hitbox.push_force_vertical, hitbox.push_force_horizontal * impact_angle.z)
		
		stun(0.4)
		
		if is_instance_valid(hitbox.caster):
			var caster_iv = hitbox.caster.get_node("Inventory") as Inventory
			if caster_iv:
				caster_iv.gold += 10


# TODO : pass through who killed the entity as an argument in the signal
func _on_entity_died():
	queue_free()
