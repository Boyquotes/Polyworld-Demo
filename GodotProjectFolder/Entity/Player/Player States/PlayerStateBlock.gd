extends State


var player : Player

var state_name = "Block"

var last_speed = 0


# TODO probably relegate the mana cost information to the Attack resource associated with this
var mana_cost := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.block_multiplier = 1


func update(_delta):
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	player.update_facing(_delta)


func physics_update(_delta):
	
	# Play correct animation
	#player.anim.play("cast2")
	
	# TODO : put this in a setter in Entity ?
	player.block_multiplier -= _delta
	if player.block_multiplier <= 0.2:
		player.block_multiplier = 0.2
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * _delta
	
	# Slow down the player
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	if player.is_on_floor():
		hor_velocity = hor_velocity.move_toward(player.relative_input_dir * player.move_speed * 0.3, player.move_accel * _delta)

	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	last_speed = player.velocity.length()
	if player.move_and_slide():
		if player.velocity.length() - last_speed < -30.0:
			player.take_damage(last_speed * 0.25)
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Dodge")
		return
	
	# Handle key release
	if !Input.is_action_pressed("special"):
		# Return to standard state
		if player.is_on_floor():
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("InAir")
		return
		

func exit():
	player.block_multiplier = 0

