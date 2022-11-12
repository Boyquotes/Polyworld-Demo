extends State


var player : Player

var attack_length = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	attack_length = 5
	var ball = load("res://Attacks/Fireball.tscn").instantiate()
	ball.caster = player
	ball.direction = Vector3(player.target_facing_dir.x, 0, player.target_facing_dir.y)
	get_tree().root.add_child(ball)
	ball.global_position = player.global_position
	


func update(delta):
	pass


func physics_update(delta):
	
	player.anim.play("thrust")
	
	# Add the gravity
	#player.velocity.y -= player.GRAVITY * delta
	
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	hor_velocity *= 0.95
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	player.move_and_slide()
	
	if player.is_on_floor():
		attack_length -= 60 * delta
	else:
		attack_length -= 40 * delta
	
	if attack_length <= 1:
		if player.is_on_floor():
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("InAir")


func exit():
	pass


func jump():
	player.velocity.y = player.JUMP_VELOCITY
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
	
