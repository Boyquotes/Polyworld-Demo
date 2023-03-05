extends State


var player : Player

var fuel = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	# Activate partner's hitbox to hit enemies
	#player.partner.get_node("Hitbox").set_deferred("monitorable", true)
	player.velocity.y = 0
	fuel = 1
	player.partner.velocity.y = 0
	player.turn_speed = 5
	pass


func update(_delta):
	player.partner.rotation.y = player.rotation.y


func physics_update(_delta):
	
	var vert_velocity = player.velocity.y
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	var partner_speed = player.move_speed * 1.3
	var partner_accel = player.move_accel * 0.3
	
	# If there is input, accelerate towards run speed
	if player.relative_input_dir:
		# Set facing direction based on run direction
		player.facing_dir_target = player.relative_input_dir
	
		hor_velocity = hor_velocity.move_toward(
			player.facing_dir.normalized() * partner_speed, partner_accel)
	else:
		player.facing_dir_target = player.facing_dir
	
	if player.is_on_floor():
		fuel = 1
		
	if fuel > 0:
		fuel -= 0.5 * _delta
		vert_velocity = abs((abs(fuel - 0.5) * 2) - 1) * 6
	if fuel <= 0:
		fuel = 0
		# Add the gravity
		vert_velocity = -2.5
	
	# Set new velocity
	player.velocity = Vector3(hor_velocity.x, vert_velocity, hor_velocity.y)
	
	# Move the player
	player.move_and_slide()
	
	player.partner.global_position = player.global_position
		
	# If partner is deactivated, hop off
	if !Input.is_action_pressed("special"):
		#player.partner.deactivate()
		player.velocity.y = player.jump_force * 0.75
		player.can_hold_jump = false
		state_machine.transition_to("InAir")
		return
	


func exit():
	# Activate partner's hitbox to hit enemies
	player.partner.get_node("Hitbox").set_deferred("monitorable", false)
	player.turn_speed = 14
	pass

