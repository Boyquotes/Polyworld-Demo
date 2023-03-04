extends State


var player : Player

var state_name = "Block"

var dodge_duration = 0.05
var dodge_timer = dodge_duration

var dodge_direction = Vector2.ZERO


# TODO probably relegate the mana cost information to the Attack resource associated with this
var mana_cost := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.is_immune = true
	dodge_timer = dodge_duration
	
	# Rotate toward target
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	
	if player.input_dir:
		dodge_direction = player.input_dir
	else:
		dodge_direction = player.facing_dir_target


func update(_delta):
	player.update_facing(_delta)


func physics_update(_delta):
	
	# Play correct animation
	#player.anim.play("cast2")
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * _delta
	
	# Slow down the player
	var hor_velocity = Vector2(dodge_direction.x, dodge_direction.y) * 60
	#hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * _delta)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	player.move_and_slide()
	
	dodge_timer -= _delta

	# Handle transitions
	if dodge_timer <= 0:
		if Input.is_action_pressed("special"):
			state_machine.transition_to("Block")
			return
		
		# Return to standard state
		if player.is_on_floor():
			state_machine.transition_to("Grounded")
		else:
			state_machine.transition_to("InAir")
		return

func exit():
	player.is_immune = false
	player.velocity.x *= 0.25
	player.velocity.y *= 0.25
	player.velocity.z *= 0.25

