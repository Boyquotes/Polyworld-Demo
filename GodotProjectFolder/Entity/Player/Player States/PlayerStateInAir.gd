extends State


var player : Player

var in_jump_buffer = false
var in_coyote_time = false


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	if not player.can_hold_jump:
		set_coyote_time()


func update(_delta):
	pass


func physics_update(_delta):
	
	if not Input.is_action_pressed("jump"):
		player.can_hold_jump = false
	
	# TODO : fix this to better detect if jumping or not
	elif Input.is_action_just_pressed("jump"):
		set_jump_buffer()
		if in_coyote_time and player.velocity.y <= 1:
			jump()
			return
	
	# Ascending
	if player.velocity.y >= 0:
		player.anim.play("inair_up")
		
		# Add gravity to velocity based on if holding jump
		if player.can_hold_jump:
			player.velocity.y -= player.GRAVITY/2 * _delta
		else:
			player.velocity.y -= player.GRAVITY * _delta
	
	# Descending
	else:
		player.anim.play("inair_down")
		player.can_hold_jump = false
		
		# Add gravity to velocity
		player.velocity.y -= player.GRAVITY * _delta
	
	# Initialize horizontal velocity
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	# Adjust velocity if there is movement input
	if player.relative_input_dir:
		hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.move_speed, player.air_accel * _delta)
		player.velocity.x = hor_velocity.x
		player.velocity.z = hor_velocity.y
		
		# Set direction to face
		player.facing_dir_target = player.relative_input_dir
	
	# Store velocity prior to moving
	var last_vel = player.velocity.y
	
	player.move_and_slide()
	
	# Handle landing
	if player.is_on_floor():
		player.s_player.stream = load("res://Sounds/landing.wav")
		player.s_player.pitch_scale = randf_range(0.8, 1.2)
		player.s_player.play()
		
		player.can_hold_jump = false
		
		# Handle fall damage
		if last_vel <= -45.0:
			player.take_damage(-last_vel * 0.25)
		
		# Handle jumping if in buffer
		if in_jump_buffer:
			jump()
			return
		
		else:
			state_machine.transition_to("Grounded")
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


func set_jump_buffer():
	in_jump_buffer = true
	await get_tree().create_timer(player.JUMP_BUFFER).timeout
	in_jump_buffer = false


func set_coyote_time():
	in_coyote_time = true
	await get_tree().create_timer(player.COYOTE_TIME).timeout
	in_coyote_time = false
