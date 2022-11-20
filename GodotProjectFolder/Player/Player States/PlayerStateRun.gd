extends State


var player : Player

var step = false


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	footstep()


func update(delta):
	pass


func physics_update(delta):
	
	player.anim.play("run")
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * delta
	
	if player.input_dir:
		
		player.set_target_facing(player.relative_input_dir)
		
		var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
		hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.RUN_SPEED, player.RUN_ACCEL * delta)
		player.velocity.x = hor_velocity.x
		player.velocity.z = hor_velocity.y
		
		#player.velocity.x = move_toward(player.velocity.x, player.relative_input_dir.x * player.RUN_SPEED, player.RUN_ACCEL * delta)
		#player.velocity.z = move_toward(player.velocity.z, player.relative_input_dir.y * player.RUN_SPEED, player.RUN_ACCEL * delta)
		
	else:
		state_machine.transition_to("Idle")
	
	player.move_and_slide()
	
	if player.is_on_floor():
		# Handle jump
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		state_machine.transition_to("InAir")
	
	
	if Input.is_action_just_pressed("left_hand"):
		if not player.is_left_cooling:
			player.is_left_cooling = true
			player.get_parent().get_parent().card_left_cooldown.start(player.left_cooldown)
			state_machine.transition_to("Attack1")
	if Input.is_action_just_pressed("right_hand"):
		if not player.is_right_cooling:
			player.is_right_cooling = true
			player.get_parent().get_parent().card_right_cooldown.start(player.right_cooldown)
			state_machine.transition_to("Attack2")
	if Input.is_action_just_pressed("special"):
		state_machine.transition_to("Attack3")


func exit():
	player.s_player.stop()


func jump():
	player.velocity.y = player.JUMP_VELOCITY
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
	
	player.s_player.stream = load("res://Sounds/jumpsound2.wav")
	player.s_player.pitch_scale = randf_range(0.8, 1.2)
	player.s_player.play()
	

func footstep():
	while state_machine.current_state == self:
		player.s_player.stream = load("res://Sounds/footstep0.wav")
		player.s_player.pitch_scale = randf_range(0.8, 1.2)
		player.s_player.play()
		await get_tree().create_timer(0.2).timeout
	
	
