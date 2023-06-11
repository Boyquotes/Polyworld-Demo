extends State


var player : Player

var in_jump_buffer = false
var in_coyote_time = false


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.anim.play("jump")
	if !player.can_hold_jump:
		set_coyote_time()
	
	player.dust_trail.emitting = false


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


func physics_update(_delta):
	
	# Disable jump holding when button is released
	if !Input.is_action_pressed("jump"):
		player.can_hold_jump = false
	
	# TODO : fix this to better detect if jumping or not, such as passing it thru as a parameter into the state
	elif Input.is_action_just_pressed("jump"):
		set_jump_buffer()
		if in_coyote_time and player.vert_velocity <= 1:
			player.jump()
			return
	
	# Add gravity to velocity, scaled based on if holding jump
	if player.vert_velocity >= 0 && player.can_hold_jump:
		player.vert_velocity -= player.GRAVITY/2 * _delta
	else:
		player.can_hold_jump = false
		player.vert_velocity -= player.GRAVITY * _delta
	
	# Check if there is input
	if player.relative_input_dir:
		
		# Set horizontal velocity
		var desired_vel = player.relative_input_dir * player.move_speed
		var desired_accel = player.air_accel * _delta
		player.hor_velocity = player.hor_velocity.move_toward(desired_vel, desired_accel)
		
		# Set direction to face
		player.facing_dir_target = player.relative_input_dir
	
	# Handle impact damage and camera shake
	var last_speed = player.velocity.length()
	if player.apply_velocities():
		var vel_difference = last_speed - player.velocity.length()
		if vel_difference > 5:
			player.cam_arm.shake_amt = clamp(vel_difference * 0.01, 0, 0.5)
			Input.start_joy_vibration(0, 0.5, 0.5, 0.1)
			if vel_difference > 40:
				player.take_damage(last_speed * 0.2)
	
	# Handle landing
	if player.is_on_floor():
		player.s_player.stream = load("res://Sounds/landing.wav")
		player.s_player.pitch_scale = randf_range(1.0, 1.2)
		player.s_player.play()
		
		player.get_node("DustPoof").restart()
		player.model.position.y = -0.25
		
		player.can_hold_jump = false
		
		# Handle jumping if in buffer
		if in_jump_buffer:
			player.jump()
			return
		state_machine.transition_to("Idle")
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


func set_jump_buffer():
	in_jump_buffer = true
	await get_tree().create_timer(player.JUMP_BUFFER).timeout
	in_jump_buffer = false


func set_coyote_time():
	in_coyote_time = true
	await get_tree().create_timer(player.COYOTE_TIME).timeout
	in_coyote_time = false
