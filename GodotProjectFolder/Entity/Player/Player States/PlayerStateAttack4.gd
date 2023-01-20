extends State


var player : Player

var attack_length = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	attack_length = 10
	
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	
	var ball = load("res://Attacks/EnergyBall.tscn").instantiate()
	ball.caster = player
	ball.direction = player.aim_direction
	get_tree().root.add_child(ball)
	ball.global_position = player.global_position
	
	player.velocity.y = 15


func update(_delta):
	pass


func physics_update(_delta):
	
	player.anim.play("thrust")
	
	# Add the gravity
	#player.velocity.y -= player.GRAVITY * _delta
	
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	#hor_velocity = hor_velocity.normalized() * attack_length
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	player.move_and_slide()
	
	if player.is_on_floor():
		attack_length -= 60 * _delta
	else:
		attack_length -= 40 * _delta
	
	if attack_length <= 5:
		if player.is_on_floor():
			state_machine.transition_to("Grounded")
		else:
			state_machine.transition_to("InAir")
			state_machine.get_node("InAir").flipping = true


func exit():
	pass
