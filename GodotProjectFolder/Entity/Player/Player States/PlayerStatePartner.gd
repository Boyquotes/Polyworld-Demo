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
	player.partner.velocity.y = 0
	
	# TODO : this is a bad method for this...
	player.turn_speed = 5
	player.partner.turn_speed = 5
	can_hop = false
	
	player.s_player.stream = load("res://Sounds/flight1.ogg")
	player.s_player.play()
	
	player.dust_trail.emitting = true
	
	player.get_node("Sprite3D").position.y = 2


func update(_delta):
	player.get_node("Sprite3D").position.y = 2
	player.partner.facing_dir_target = player.facing_dir_target
	player.partner.calling_end_pos = player.global_position


func physics_update(_delta):
	
	var vert_velocity = player.velocity.y
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	# TODO : make these export vars ? or keep them as modifiers of the base player stats?
	var partner_speed = player.move_speed * 1.5
	var partner_accel = player.move_accel * 0.6
	var partner_decel = player.move_decel * 0.6
	
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
			Vector2.ZERO, partner_decel * _delta)
	
	# Add the gravity
	vert_velocity -= player.GRAVITY * 1.5 * _delta
	
	# Add bumpiness
	var bumpiness = 2
	var bump_velocity = 0
	if player.is_on_floor():
		bump_velocity = pow(randf()*2, 2) * clamp(hor_velocity.length() / (player.move_speed*1.75), 0, 1) * bumpiness
	vert_velocity += bump_velocity
	
	# Set new velocity
	player.velocity = Vector3(hor_velocity.x, vert_velocity, hor_velocity.y)
	
	# Turn on hitbox to hit enemies at high speeds
	player.partner.get_node("Hitbox").set_deferred("monitorable", hor_velocity.length() > player.move_speed * 1.2)
	
	# Move the player
	player.move_and_slide()
	
	player.partner.global_position = player.global_position
	
	if player.is_on_floor() and vert_velocity < -0.5:
		player.velocity.y = -vert_velocity * 0.25
		can_hop = true
	
	if Input.is_action_just_pressed("jump"):
		if can_hop:
			player.velocity.x += player.facing_dir_target.x * partner_speed * 0.6
			player.velocity.z += player.facing_dir_target.y * partner_speed * 0.6
			player.velocity.y += player.jump_force * 2 * (1.0 - clamp(Vector2(player.velocity.x, player.velocity.z).length() / partner_speed, 0.3, 0.6)) - bump_velocity
			can_hop = false
			player.cam.get_parent().shake_amt = 0.15
		
	# If partner is deactivated, hop off
	if !Input.is_action_pressed("special"):
		#player.partner.deactivate()
		player.partner.is_being_called = false
		player.partner.velocity = Vector3(0, 15, 0)
		player.velocity.y = player.jump_force * 0.75
		player.can_hold_jump = false
		state_machine.transition_to("InAir")
		return
	


func exit():
	# Activate partner's hitbox to hit enemies
	player.partner.get_node("Hitbox").set_deferred("monitorable", false)
	player.dust_trail.emitting = false
	player.turn_speed = 14
	player.partner.turn_speed = 14
	
	player.get_node("Sprite3D").position.y = 0.4
	pass

