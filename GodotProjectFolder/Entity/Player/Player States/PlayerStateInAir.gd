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
	
	elif Input.is_action_just_pressed("jump"):
		set_jump_buffer()
		if in_coyote_time and player.velocity.y <= 1:
			jump()
	
	# Add the appropriate gravity
	if player.velocity.y >= 0:
		player.anim.play("inair_up")
		if player.can_hold_jump:
			player.velocity.y -= player.GRAVITY / 2 * _delta
		else:
			player.velocity.y -= player.GRAVITY * _delta
	else:
		player.anim.play("inair_down")
		player.velocity.y -= player.GRAVITY * _delta
		player.can_hold_jump = false
	
	if player.input_dir:
		
		player.facing_dir_target = player.relative_input_dir
		
		var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
		hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.move_speed, player.air_accel * _delta)
		player.velocity.x = hor_velocity.x
		player.velocity.z = hor_velocity.y
	
	var last_vel = player.velocity.y
	
	player.move_and_slide()
	
	
	# Handle landing
	if player.is_on_floor():
		player.can_hold_jump = false
		
		player.s_player.stream = load("res://Sounds/landing.wav")
		player.s_player.pitch_scale = randf_range(0.8, 1.2)
		player.s_player.play()
		
		if last_vel <= -45.0:
			player.take_damage(-last_vel * 0.25)
			return
		
		if in_jump_buffer:
			jump()
		else:
			if player.input_dir:
				state_machine.transition_to("Run")
			else: 
				state_machine.transition_to("Idle")
	
	# Handle state transitions
	if Input.is_action_just_pressed("primary"):
		state_machine.transition_to("Attack1")
	if Input.is_action_just_pressed("secondary"):
		state_machine.transition_to("Attack2")
	if Input.is_action_just_pressed("tertiary"):
		state_machine.transition_to("Attack3")


func exit():
	pass
	#var model = player.get_node("Model") as Node3D


func jump():
	
	player.can_hold_jump = true
	player.velocity.y = player.jump_force
		


func set_jump_buffer():
	in_jump_buffer = true
	await get_tree().create_timer(player.JUMP_BUFFER).timeout
	in_jump_buffer = false
	


func set_coyote_time():
	in_coyote_time = true
	await get_tree().create_timer(player.COYOTE_TIME).timeout
	in_coyote_time = false
	
