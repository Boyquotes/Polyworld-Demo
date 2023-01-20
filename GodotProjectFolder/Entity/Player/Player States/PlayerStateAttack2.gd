extends State


var player : Player

var stored_velocity : Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	
	# Store initial velocity
	stored_velocity = player.velocity
	
	# Rotate toward target
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	
	# Hop up in the air
	player.velocity.y = 2
	
	# Wait a second
	await get_tree().create_timer(0.2).timeout
	
	# Spawn attack
	var ball = load("res://Attacks/Fireball.tscn").instantiate()
	ball.caster = player
	ball.direction = player.aim_direction
	get_tree().root.add_child(ball)
	ball.global_position = player.global_position
	
	# Wait a second
	await get_tree().create_timer(0.05).timeout
	
	# Return to standard state
	if player.is_on_floor():
		state_machine.transition_to("Grounded")
	else:
		state_machine.transition_to("InAir")
	


func update(_delta):
	pass


func physics_update(_delta):
	
	# Play correct animation
	player.anim.play("cast1")
	
	# Slow down the player
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * 0.5 * _delta)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	player.move_and_slide()


func exit():
	
	# Return to initial velocity
	player.velocity.x = stored_velocity.x
	player.velocity.z = stored_velocity.z
	

