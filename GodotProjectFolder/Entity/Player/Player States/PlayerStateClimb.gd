extends State


var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.velocity = Vector3.ZERO


func update(_delta):
	pass


func physics_update(_delta):
	
	if player.input_dir.y != 0:
		#climbing vertically
		player.velocity.y = move_toward(player.velocity.y, player.climb_speed * -sign(player.input_dir.y), player.move_accel * _delta)
	else:
		#stopped
		player.velocity.y = move_toward(player.velocity.y, 0, player.move_decel * _delta)
		
	#player.set_facing_target(player.relative_input_dir)
	
	player.move_and_slide()
	
	if Input.is_action_just_pressed("jump"):
		jump()
	

func exit():
	pass


func jump():
	player.velocity.x = -player.facing_dir_target.x * player.jump_force
	player.velocity.y = player.jump_force
	player.velocity.z = -player.facing_dir_target.y * player.jump_force
	
	player.facing_dir_target = -player.relative_input_dir
	
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
	
	player.s_player.stream = load("res://Sounds/jumpsound2.wav")
	player.s_player.pitch_scale = randf_range(0.8, 1.2)
	player.s_player.play()
	
