extends State


var player : Player


var stored_velocity : Vector3



# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner
	


func enter():
	stored_velocity = player.velocity
	
	
	player.target_facing_dir = Vector2(player.aim_direction.x, player.aim_direction.z)
	player.velocity.y = 2

	await get_tree().create_timer(0.2).timeout
	
	var ball = load("res://Attacks/Fireball.tscn").instantiate()
	ball.caster = player
	ball.direction = player.aim_direction
	get_tree().root.add_child(ball)
	ball.global_position = player.global_position
	
	
	await get_tree().create_timer(0.05).timeout
	
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("InAir")
	


func update(delta):
	pass


func physics_update(delta):
	player.anim.play("cast1")
	
	#player.target_facing_dir = Vector2(player.aim_direction.x, player.aim_direction.z)
	
	# Add the gravity
	#player.velocity.y -= player.GRAVITY * delta
	
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.RUN_DECEL * 0.5 * delta)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	player.move_and_slide()


func exit():
	#pass
	player.velocity.x = stored_velocity.x
	player.velocity.z = stored_velocity.z
	

