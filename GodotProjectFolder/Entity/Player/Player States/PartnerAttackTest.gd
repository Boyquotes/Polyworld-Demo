extends State


var player : Player

var state_name = "PartnerAttackTest"


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	
	# Rotate toward target
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	player.partner.facing_dir_target = player.facing_dir_target
	
	player.partner.summon(0.15, player.global_position + player.aim_direction * 2)
	
	player.hor_velocity = Vector2(player.aim_direction.x, player.aim_direction.z).normalized() * player.move_speed


func update(_delta):
	
	player.hor_velocity = Vector2(player.aim_direction.x, player.aim_direction.z).normalized() * player.move_speed
	
	player.partner.summon_destination = player.global_position + player.aim_direction * 2
	
	if player.partner.reached_summon_destination:
		player.partner.is_being_summoned = false
		player.partner.velocity = Vector3(0, 15, 0)
	
	# TODO : better system for checking if an attack has been completed
	if !player.partner.is_being_summoned:
		# Return to standard state
		if player.is_on_floor():
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("InAir")


func physics_update(_delta):

	# Ascending
	if !player.is_on_floor() && player.vert_velocity >= 0:
		# Add gravity to velocity based on if holding jump
		if player.can_hold_jump:
			player.vert_velocity -= player.GRAVITY/2 * _delta
		else:
			player.vert_velocity -= player.GRAVITY * _delta
	
	# Descending
	else:
		player.can_hold_jump = false
		
		# Add gravity to velocity
		player.vert_velocity -= player.GRAVITY * _delta
	
	player.apply_velocities()


func exit():
	pass
	# Return to initial velocity
#	player.velocity.x = stored_velocity.x
#	player.velocity.z = stored_velocity.z
	

