extends State


var player : Player

var in_jump_buffer = false
var in_coyote_time = false

var flipping = false


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	if not player.can_hold_jump:
		set_coyote_time()


func update(delta):
	pass


func physics_update(delta):
	
	if not Input.is_action_pressed("jump"):
		player.can_hold_jump = false
	
	elif Input.is_action_just_pressed("jump"):
		set_jump_buffer()
		if in_coyote_time and player.velocity.y <= 1:
			jump()
	
	# Add the appropriate gravity
	if player.velocity.y >= 0:
		player.anim.play("inair_up")
		if player.can_hold_jump:
			player.velocity.y -= player.HOLD_GRAVITY * delta
		else:
			player.velocity.y -= player.GRAVITY * delta
	else:
		player.anim.play("inair_down")
		player.velocity.y -= player.GRAVITY * delta
		player.can_hold_jump = false
	
	if player.input_dir:
		
		player.set_target_facing(player.relative_input_dir)
		
		var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
		hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.RUN_SPEED, player.AIR_ACCEL * delta)
		player.velocity.x = hor_velocity.x
		player.velocity.z = hor_velocity.y
	
	
	player.move_and_slide()
	
	if flipping:
		var model = player.get_node("Model") as Node3D
		#model.rotate_x(0.15)
		model.rotation.x = move_toward(model.rotation.x, TAU - 0.1, 0.2)
		if model.rotation.x < TAU - 0.2:
			player.anim.play("frontflip")
	
	
	# Handle landing
	if player.is_on_floor():
		player.can_hold_jump = false
		
		if player.velocity.y <= -40.0:
			print("fall damage")
		
		if in_jump_buffer:
			jump()
		else:
			if player.input_dir:
				state_machine.transition_to("Run")
			else: 
				state_machine.transition_to("Idle")
	
	if Input.is_action_just_pressed("primary"):
		if not player.is_left_cooling:
			player.is_left_cooling = true
			player.get_parent().get_parent().card_left_cooldown.start(player.left_cooldown)
			state_machine.transition_to("Attack1")
	if Input.is_action_just_pressed("secondary"):
		if not player.is_right_cooling:
			player.is_right_cooling = true
			player.get_parent().get_parent().card_right_cooldown.start(player.right_cooldown)
			state_machine.transition_to("Attack2")
	if Input.is_action_just_pressed("special"):
		state_machine.transition_to("Attack3")
	if Input.is_action_just_pressed("tertiary"):
		state_machine.transition_to("Attack4")


func exit():
	player.s_player.stream = load("res://Sounds/landing.wav")
	player.s_player.pitch_scale = randf_range(0.8, 1.2)
	player.s_player.play()
	
	var model = player.get_node("Model") as Node3D
	model.rotation.x = 0
	flipping = false


func jump():
	
	player.can_hold_jump = true
	
	var fl = flipping
	state_machine.transition_to("InAir")
	flipping = !fl
	if flipping:
		player.velocity.y = player.JUMP_VELOCITY * 1.2
	else:
		player.velocity.y = player.JUMP_VELOCITY
		


func set_jump_buffer():
	in_jump_buffer = true
	await get_tree().create_timer(player.JUMP_BUFFER).timeout
	in_jump_buffer = false
	


func set_coyote_time():
	in_coyote_time = true
	await get_tree().create_timer(player.COYOTE_TIME).timeout
	in_coyote_time = false
	
