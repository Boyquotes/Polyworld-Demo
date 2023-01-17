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
	
	var ball = load("res://Attacks/Grabber.tscn").instantiate()
	ball.caster = player
	ball.direction = player.aim_direction
	get_tree().root.add_child(ball)
	ball.global_position = player.global_position
	
	player.velocity.y = 15
	


func update(delta):
	pass


func physics_update(delta):
	
	player.anim.play("thrust")
	
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	player.move_and_slide()
	
	if player.is_on_floor():
		attack_length -= 60 * delta
	else:
		attack_length -= 40 * delta
	
	if attack_length <= 5:
		if player.is_on_floor():
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("InAir")


func exit():
	pass


func jump():
	player.velocity.y = player.jump_force
	player.can_hold_jump = true
	state_machine.transition_to("InAir")
	
