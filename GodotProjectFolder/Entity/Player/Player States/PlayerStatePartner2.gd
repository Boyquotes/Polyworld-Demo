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
	
	player.anim.play("jump")
	
	player.s_player.stream = load("res://Sounds/flight1.ogg")
	player.s_player.play()
	
	player.dust_trail.emitting = true


func update(_delta):
	player.partner.rotation.y = player.rotation.y


func physics_update(_delta):
	
	var partner_speed = player.move_speed * 1.2
	var partner_accel = player.move_accel * 0.6
	
	# If there is input, accelerate towards run speed
	if player.relative_input_dir:
		# Set facing direction based on run direction
		player.facing_dir_target = player.relative_input_dir
	else:
		player.facing_dir_target = player.facing_dir
	
	player.hor_velocity = player.hor_velocity.move_toward(
		player.facing_dir.normalized() * partner_speed, partner_accel * _delta)
	
	if player.is_on_floor():
		fuel = 1
		
	if fuel > 0:
		fuel -= 0.5 * _delta
		player.vert_velocity = abs((abs(fuel - 0.5) * 2) - 1) * 6
	if fuel <= 0:
		fuel = 0
		# Add the gravity
		player.vert_velocity = -2.5
	
	# Move the player
	player.apply_velocities()
	
	# Position partner on player
	player.partner.summon_destination = player.global_position
		
	# If partner is deactivated, hop off
	if !Input.is_action_pressed("special"):
		player.partner.is_being_summoned = false
		player.partner.velocity = Vector3(0, 15, 0)
		player.vert_velocity = player.jump_force * 0.75
		player.can_hold_jump = false
		state_machine.transition_to("InAir")
		return
	


func exit():
	
	player.dust_trail.emitting = false
	player.s_player.stop()
	# Activate partner's hitbox to hit enemies
	player.partner.get_node("Hitbox").set_deferred("monitorable", false)
	player.turn_speed = 14
	pass

