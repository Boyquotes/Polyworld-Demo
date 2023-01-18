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
	
	player.anim.play("idle")
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * _delta
	
	if player.input_dir:
		state_machine.transition_to("Run")
		
	else:
		
		var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
		hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * _delta)
		player.velocity.x = hor_velocity.x
		player.velocity.z = hor_velocity.y
	
	player.move_and_slide()
	
	if player.is_on_floor():
		# Handle jump
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		state_machine.transition_to("InAir")
	
	
	if Input.is_action_just_pressed("primary"):
		state_machine.transition_to("Attack1")
	if Input.is_action_just_pressed("secondary"):
		state_machine.transition_to("Attack2")
	if Input.is_action_just_pressed("tertiary"):
		state_machine.transition_to("Attack3")


func exit():
	pass


func jump():
	player.velocity.y = player.jump_force
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
	
	player.s_player.stream = load("res://Sounds/jumpsound3.wav")
	player.s_player.pitch_scale = randf_range(0.8, 1.2)
	player.s_player.play()
