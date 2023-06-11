extends State


var player : Player

var can_hop = true


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	# Activate partner's hitbox to hit enemies
	#player.partner.get_node("Hitbox").set_deferred("monitorable", true)
	player.partner.vert_velocity = 0
	
	player.anim.play("jump")
	
	# TODO : this is a bad method for this...
	player.turn_speed = 5
	player.partner.turn_speed = 5
	can_hop = false
	
	player.s_player.stream = load("res://Sounds/flight1.ogg")
	player.s_player.play()
	
	player.dust_trail.emitting = true
	
	player.model.position.y = 2


func update(_delta):
	player.model.position.y = 2
	player.partner.facing_dir_target = player.facing_dir_target
	player.partner.velocity = player.velocity
	
	#Input.start_joy_vibration(0, 0.05, 0.05, 0.01)


func physics_update(delta):
	
	# TODO : make these export vars ? or keep them as modifiers of the base player stats?
	var partner_speed = player.move_speed * 1.5
	var partner_accel = player.move_accel * 0.6
	var partner_decel = player.move_decel * 0.6
	
	# Check if there is input
	if player.relative_input_dir:
		# Accelerate towards run speed
		player.hor_velocity = player.hor_velocity.move_toward(
			player.relative_input_dir * partner_speed, partner_accel * delta)
		# Set facing direction based on run direction
		player.facing_dir_target = player.relative_input_dir
	else:
		# Decelerate towards zero
		player.hor_velocity = player.hor_velocity.move_toward(
			Vector2.ZERO, partner_decel * delta)
	
	# Add the gravity
	player.vert_velocity -= player.GRAVITY * 1.5 * delta
	
	# Add bumpiness
	var bumpiness = 2
	var bump_velocity = 0
	if player.is_on_floor():
		bump_velocity = pow(randf()*2, 2) * clamp(player.hor_velocity.length() / partner_speed, 0, 1) * bumpiness
	#player.vert_velocity += bump_velocity
	
	# Turn on hitbox to hit enemies at high speeds
	player.partner.get_node("Hitbox").set_deferred("monitorable", player.hor_velocity.length() > player.move_speed * 1.2)
	
	# Move the player and handle bounciness
	var last_vert_speed = player.velocity.y
	if player.apply_velocities():
		if player.is_on_floor():
			player.vert_velocity = clamp(player.vert_velocity - last_vert_speed * 0.25, 0, 20)
			can_hop = true
	
	# Position partner on player
	player.partner.summon_destination = player.global_position
	
	# Handle hopping
	if Input.is_action_just_pressed("jump"):
		if can_hop:
			player.hor_velocity += player.facing_dir_target * partner_speed * 0.6
			player.vert_velocity += player.jump_force * 2 * (1.0 - clamp(Vector2(player.velocity.x, player.velocity.z).length() / partner_speed, 0.3, 0.6))
			can_hop = false
			player.cam_arm.shake_amt = 0.15
			Input.start_joy_vibration(0, 0.65, 0.65, 0.1)
		
	# If partner is deactivated, hop off
	if !Input.is_action_pressed("special"):
		player.partner.is_being_summoned = false
		player.partner.velocity = Vector3(0, 15, 0)
		player.vert_velocity = player.jump_force * 0.75
		player.can_hold_jump = false
		state_machine.transition_to("InAir")
		return
		


func exit():
	# Activate partner's hitbox to hit enemies
	player.partner.get_node("Hitbox").set_deferred("monitorable", false)
	player.dust_trail.emitting = false
	player.turn_speed = 14
	player.partner.turn_speed = 14
	
	player.model.position.y = 0.12
	

