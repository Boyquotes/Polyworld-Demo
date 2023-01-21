extends State


var player : Player

var state_name = "Restore"


# TODO probably relegate the mana cost information to the Attack resource associated with this
var mana_cost := 1

var regen_interval = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	pass


func update(_delta):
	
	regen_interval -= _delta
	if regen_interval <= 0:
		
		# Attempt to use mana, and return if there isn't enough
		if !player.decrease_mana(mana_cost):
			if player.is_on_floor():
				state_machine.transition_to("Grounded")
			else:
				state_machine.transition_to("InAir")
			return
			
		player.heal(1)
		
		regen_interval = 0.25


func physics_update(_delta):
	
	# Play correct animation
	player.anim.play("cast2")
	
	# Slow down the player
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * 0.25 * _delta)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	player.move_and_slide()
	
	# Handle key release
	if name == "Primary":
		if !Input.is_action_pressed("primary"):
			# Return to standard state
			if player.is_on_floor():
				state_machine.transition_to("Grounded")
			else:
				state_machine.transition_to("InAir")
			return
	if name == "Secondary":
		if !Input.is_action_pressed("secondary"):
			# Return to standard state
			if player.is_on_floor():
				state_machine.transition_to("Grounded")
			else:
				state_machine.transition_to("InAir")
			return

func exit():
	pass

