extends State


var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	pass


func update(_delta):
	pass


func physics_update(_delta):
	
	# Add gravity to velocity
	player.velocity.y -= player.GRAVITY * _delta
	
	# Initialize horizontal velocity
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	# Running
	if player.relative_input_dir:
		player.anim.play("run")
		hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.move_speed, player.move_accel * _delta)
		
		# Set direction to face
		player.facing_dir_target = player.relative_input_dir
		
	# Idle
	else:
		player.anim.play("idle")
		hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * _delta)
	
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
			
	else:
		state_machine.transition_to("InAir")
		return
	
	# Handle attacking
	if Input.is_action_just_pressed("primary"):
		#player.attempt_attack("Primary")
		state_machine.transition_to("Primary")
		return
	if Input.is_action_just_pressed("secondary"):
		#player.attempt_attack("Secondary")
		state_machine.transition_to("Secondary")
		return


func exit():
	pass


func jump():
	player.s_player.stream = load("res://Sounds/jumpsound3.wav")
	player.s_player.pitch_scale = randf_range(0.8, 1.2)
	player.s_player.play()
	
	player.velocity.y = player.jump_force
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
