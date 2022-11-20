extends State


var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	pass


func update(delta):
	pass


func physics_update(delta):
	
	player.anim.play("idle")
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * delta
	
	if player.input_dir:
		state_machine.transition_to("Run")
		
	else:
		
		var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
		hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.RUN_DECEL * delta)
		player.velocity.x = hor_velocity.x
		player.velocity.z = hor_velocity.y
		
		#player.velocity.x = move_toward(player.velocity.x, 0, player.RUN_DECEL * delta)
		#player.velocity.z = move_toward(player.velocity.z, 0, player.RUN_DECEL * delta)
		
	
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
	pass


func jump():
	player.velocity.y = player.JUMP_VELOCITY
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
	
	player.s_player.stream = load("res://Sounds/jumpsound3.wav")
	player.s_player.pitch_scale = randf_range(0.8, 1.2)
	player.s_player.play()
