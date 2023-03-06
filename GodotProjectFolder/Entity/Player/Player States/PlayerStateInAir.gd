extends State


var player : Player

var in_jump_buffer = false
var in_coyote_time = false

var wall_sliding = false
var wall_normal = Vector3.UP:
	set(val):
		wall_normal_2d = Vector2(val.x, val.z).normalized()
		wall_normal = val
var wall_normal_2d = Vector2.UP
var wall_slide_fuel = 1.0:
	set(val):
		wall_slide_fuel = clamp(val, 0, 1)


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.anim.play("jump")
	if not player.can_hold_jump:
		set_coyote_time()
	wall_slide_fuel = 1.0


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
	
	# Initialize horizontal velocity
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	if not Input.is_action_pressed("jump"):
		player.can_hold_jump = false
	
	# TODO : fix this to better detect if jumping or not, such as passing it thru as a parameter into the state
	elif Input.is_action_just_pressed("jump"):
		# WALL JUMP STUFF
		if wall_sliding:
			wall_sliding = false
			hor_velocity = wall_normal_2d * 15 + hor_velocity
			player.velocity.x = hor_velocity.x
			player.velocity.z = hor_velocity.y
			player.velocity.y = player.jump_force * 1.2
			player.facing_dir_target = hor_velocity.normalized()
			player.anim.play("jump", 0)
			
		##
		else:
			set_jump_buffer()
			if in_coyote_time and player.velocity.y <= 1:
				jump()
				return
	
	# Ascending
	if player.velocity.y >= 0:
		#player.anim.play("inair_up")
		
		# Add gravity to velocity based on if holding jump
		if player.can_hold_jump:
			player.velocity.y -= player.GRAVITY/2 * _delta
		else:
			player.velocity.y -= player.GRAVITY * _delta
	
	# Descending
	else:
		#player.anim.play("inair_down")
		player.can_hold_jump = false
		
		# Add gravity to velocity
		player.velocity.y -= player.GRAVITY * _delta
	
	# Adjust velocity if there is movement input
	if player.relative_input_dir:
		hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.move_speed, player.air_accel * _delta)
		player.velocity.x = hor_velocity.x
		player.velocity.z = hor_velocity.y
		
		# Set direction to face
		player.facing_dir_target = player.relative_input_dir
	
	# Store velocity prior to moving
	var last_speed = player.velocity.length()
	if player.move_and_slide():
		# Handle fall damage
		if  last_speed - player.velocity.length() > 40:
			player.take_damage(last_speed * 0.2)
	
	if wall_sliding:
		wall_slide_fuel -= 0.05
		player.velocity.y *= 1.0 - wall_slide_fuel * 0.5
		var wall_angle = player.facing_dir_target.dot(wall_normal_2d)
		if wall_angle >= 0.1:
			wall_sliding = false
	elif wall_slide_fuel > 0 && player.is_on_wall():
		wall_normal = player.get_wall_normal()
		var wall_angle = hor_velocity.dot(wall_normal_2d)
		if wall_angle < -0.25:
			wall_sliding = true
	
	
	# Handle landing
	if player.is_on_floor():
		player.s_player.stream = load("res://Sounds/landing.wav")
		player.s_player.pitch_scale = randf_range(0.8, 1.2)
		player.s_player.play()
		
		player.can_hold_jump = false
		
		# Handle jumping if in buffer
		if in_jump_buffer:
			jump()
			return
		
		else:
			state_machine.transition_to("Grounded")
			return
	
	# Handle attacking
	if Input.is_action_just_pressed("primary"):
		state_machine.transition_to("Primary")
		return
	if Input.is_action_just_pressed("secondary"):
		state_machine.transition_to("Secondary")
		return


func exit():
	wall_sliding = false


func jump():
	#player.s_player.stream = load("res://Sounds/jumpsound3.wav")
	#player.s_player.pitch_scale = randf_range(0.8, 1.2)
	#player.s_player.play()
	
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
