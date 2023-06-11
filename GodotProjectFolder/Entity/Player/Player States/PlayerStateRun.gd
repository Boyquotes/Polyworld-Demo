extends State


var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	# Play appropriate animation
	player.anim.play("run")
	player.dust_trail.emitting = true


func update(_delta):
	
	# Handle partner special ability activation
	if Input.is_action_pressed("special"):
		if !player.partner.is_being_summoned:
			player.partner.summon(0.25, player.global_position)
		player.partner.summon_destination = player.global_position
		if player.partner.reached_summon_destination:
			state_machine.transition_to("Partner")
	else:
		player.partner.is_being_summoned = false


func physics_update(delta):
	
	# Add gravity to velocity
	player.vert_velocity -= player.GRAVITY * delta
	
	# Check if there is input
	if player.relative_input_dir:
		
		# Increase acceleration when making sharp turns
		var accel_multiplier = 1
		if abs(player.hor_velocity.angle_to(player.relative_input_dir)) > PI/2:
			accel_multiplier = 3
		
		# Set horizontal velocity
		var desired_vel = player.relative_input_dir * player.move_speed
		var desired_accel = player.move_accel * accel_multiplier * delta
		player.hor_velocity = player.hor_velocity.move_toward(desired_vel, desired_accel)
		
		# Set direction to face
		player.facing_dir_target = player.relative_input_dir
		
	# Handle soft collisions
	player.hor_velocity += player.soft_collider.get_push_vector()
	
	# Apply the velocity
	player.apply_velocities()
	
	# Transition states accordingly
	if player.is_on_floor():
		if Input.is_action_just_pressed("jump"):
			player.jump()
			return
		elif player.relative_input_dir == Vector2.ZERO:
			state_machine.transition_to("Idle")
			return
	else:
		state_machine.transition_to("InAir")
		return
	
	# TODO : modify this for the new state-based combat system
	# Handle attacking
	if Input.is_action_just_pressed("primary"):
		state_machine.transition_to("Primary")
		return
	if Input.is_action_just_pressed("secondary"):
		state_machine.transition_to("Secondary")
		return


func exit():
	player.dust_trail.emitting = false

