extends State


var player : Player

var state_name = "Block"

var block_timer = 1.0


# TODO probably relegate the mana cost information to the Attack resource associated with this
var mana_cost := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	block_timer = 1.0


func update(_delta):
	player.face_toward(player.aim_target.global_position)
	player.update_facing(_delta)


func physics_update(_delta):
	
	# Play correct animation
	player.anim.play("cast2")
	
	block_timer -= _delta
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * _delta
	
	# Slow down the player
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * _delta)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	player.move_and_slide()
	
	# Handle key release
	if !Input.is_action_pressed("special"):
		# Return to standard state
		if player.is_on_floor():
			state_machine.transition_to("Grounded")
		else:
			state_machine.transition_to("InAir")
		return

func exit():
	pass

