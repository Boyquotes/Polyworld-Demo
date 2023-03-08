extends State


var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.anim.play("run")
	player.dust_trail.emitting = true


func update(_delta):
	
	# Handle partner activation
	if Input.is_action_pressed("special"):
		player.partner.is_being_called = true
		if Input.is_action_just_pressed("special"):
			player.partner_activation_time = 0.0
			player.partner_activation_position = player.partner.global_position
		player.partner_activation_time += _delta * 2
		if player.partner_activation_time >= 0.5:
			player.partner_activation_time = 1.0
			state_machine.transition_to("Partner")
		player.partner.global_position = player.partner.global_position.lerp(player.global_position, player.partner_activation_time)
		player.partner.rotation.y = player.rotation.y
	else:
		player.partner.is_being_called = false
		player.partner_activation_time = 0.0 


func physics_update(_delta):
	
	# Add gravity to velocity
	player.velocity.y -= player.GRAVITY * _delta
	
	# Initialize horizontal velocity
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	# Running
	if player.relative_input_dir:
		
		if abs(hor_velocity.angle_to(player.relative_input_dir)) < PI/2:
			hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.move_speed, player.move_accel * _delta)
		else:
			hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.move_speed, player.move_accel * 3 * _delta)
		
		# Set direction to face
		player.facing_dir_target = player.relative_input_dir
		
		# Apply movement
		player.velocity.x = hor_velocity.x
		player.velocity.z = hor_velocity.y
		player.move_and_slide()
	
	
	# Check if still grounded, and transition states if not
	if player.is_on_floor():
		
		# Handle jumping
		if Input.is_action_just_pressed("jump"):
			jump()
			return
		elif player.relative_input_dir == Vector2.ZERO:
			state_machine.transition_to("Idle")
			return
			
	else:
		state_machine.transition_to("InAir")
		return
	
	# Handle attacking
	if Input.is_action_just_pressed("primary"):
		state_machine.transition_to("Primary")
		return
	if Input.is_action_just_pressed("secondary"):
		state_machine.transition_to("Secondary")
		return


func exit():
	player.dust_trail.emitting = false


func jump():
	#player.s_player.stream = load("res://Sounds/jumpsound3.wav")
	#player.s_player.pitch_scale = randf_range(0.8, 1.2)
	#player.s_player.play()
	
	player.velocity.y = player.jump_force
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
