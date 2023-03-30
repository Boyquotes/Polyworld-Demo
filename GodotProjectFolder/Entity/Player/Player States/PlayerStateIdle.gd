extends State


var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.anim.play("idle")
	player.dust_trail.emitting = false


func update(_delta):
	
	# Handle partner activation
#	if Input.is_action_pressed("special"):
#		player.partner.is_being_called = true
#		if Input.is_action_just_pressed("special"):
#			player.partner_activation_time = 0.0
#			player.partner_activation_position = player.partner.global_position
#		player.partner_activation_time += _delta * 2
#		if player.partner_activation_time >= 0.5:
#			player.partner_activation_time = 1.0
#			state_machine.transition_to("Partner")
#		player.partner.global_position = player.partner.global_position.lerp(player.global_position, player.partner_activation_time)
#		player.partner.facing_dir_target = player.facing_dir_target
#	else:
#		player.partner.is_being_called = false
#		player.partner_activation_time = 0.0 
	
	if Input.is_action_pressed("special"):
		if Input.is_action_just_pressed("special"):
			player.partner.call_toward(player.global_position, 0.25)
		player.partner.calling_end_pos = player.global_position
		if player.partner.call_arrived:
			state_machine.transition_to("Partner")
	else:
		player.partner.is_being_called = false


func physics_update(_delta):
	
	# Add gravity to velocity
	player.velocity.y -= player.GRAVITY * _delta
	
	# Initialize horizontal velocity
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	# Idle
	hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * _delta)
	
	# Apply movement
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	var push_vector = player.soft_collider.get_push_vector()
	player.velocity.x += push_vector.x
	player.velocity.z += push_vector.y
	
	player.move_and_slide()
	
	# Check if still grounded, and transition states if not
	if player.is_on_floor():
		
		# Handle jumping
		if Input.is_action_just_pressed("jump"):
			jump()
			return
		elif player.relative_input_dir != Vector2.ZERO:
			state_machine.transition_to("Run")
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
	pass


func jump():
	player.s_player.stream = load("res://Sounds/jumpsound3.wav")
	player.s_player.pitch_scale = randf_range(1.0, 1.2)
	player.s_player.play()
	
	player.get_node("DustPoof").restart()
	#player.cam.get_parent().shake_amt = 0.5
	
	player.velocity.y = player.jump_force
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
