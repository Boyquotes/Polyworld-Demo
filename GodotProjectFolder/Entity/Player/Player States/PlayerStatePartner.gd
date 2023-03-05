extends State


var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	# Activate partner's hitbox to hit enemies
	#player.partner.get_node("Hitbox").set_deferred("monitorable", true)
	player.partner.velocity.y = 0
	pass


func update(_delta):
	player.partner.rotation.y = player.rotation.y


func physics_update(_delta):
	
	var vert_velocity = player.velocity.y
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	var partner_speed = player.move_speed * 1.75
	var partner_accel = player.move_accel * 0.5
	
	# If there is input, accelerate towards run speed
	if player.relative_input_dir:
		# Accelerate towards run speed
		hor_velocity = hor_velocity.move_toward(
			player.relative_input_dir * partner_speed, partner_accel * _delta)
		# Set facing direction based on run direction
		player.facing_dir_target = player.relative_input_dir
	else:
		# Decelerate towards zero
		hor_velocity = hor_velocity.move_toward(
			Vector2.ZERO, player.move_decel * 0.6 * _delta)
	
	# Add the gravity
	vert_velocity -= player.GRAVITY * 1.5 * _delta
	
	# Add bumpiness
	if player.is_on_floor():
		var bumpiness = 1.5
		vert_velocity += pow(randf()*2, 2) * clamp(hor_velocity.length() / (player.move_speed*1.75), 0, 1) * bumpiness
	
	# Set new velocity
	player.velocity = Vector3(hor_velocity.x, vert_velocity, hor_velocity.y)
	
	player.partner.get_node("Hitbox").set_deferred("monitorable", hor_velocity.length() > player.move_speed)
	
	# Move the player
	player.move_and_slide()
	
	player.partner.global_position = player.global_position
	
	if player.is_on_floor() and vert_velocity < -2:
		player.velocity.y = -vert_velocity * 0.25
		
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
	pass

