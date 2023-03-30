extends State


var player : Player

var state_name = "PartnerAttackTest"


# TODO probably relegate the mana cost information to the Attack resource associated with this
var mana_cost := 3
var stored_velocity : Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	
	# Store initial velocity
	stored_velocity = player.velocity
	
	# Rotate toward target
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	player.partner.facing_dir_target = player.facing_dir_target
	
	player.partner.call_toward(player.global_position + player.aim_direction * 2, 0.15)
	
	var hor_velocity = Vector2(player.aim_direction.x, player.aim_direction.z).normalized() * player.move_speed
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y


func update(_delta):
	
	var hor_velocity = Vector2(player.aim_direction.x, player.aim_direction.z).normalized() * player.move_speed
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	player.partner.calling_end_pos = player.global_position + player.aim_direction * 2
	
	if player.partner.call_arrived:
		await get_tree().create_timer(1).timeout # this fucks up because it runs it many times
		player.partner.is_being_called = false
	
	# TODO : better system for checking if an attack has been completed
	if !player.partner.is_being_called:
		# Return to standard state
		if player.is_on_floor():
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("InAir")


func physics_update(_delta):

	# Ascending
	if !player.is_on_floor() && player.velocity.y >= 0:
		# Add gravity to velocity based on if holding jump
		if player.can_hold_jump:
			player.velocity.y -= player.GRAVITY/2 * _delta
		else:
			player.velocity.y -= player.GRAVITY * _delta
	
	# Descending
	else:
		player.can_hold_jump = false
		
		# Add gravity to velocity
		player.velocity.y -= player.GRAVITY * _delta
	
	player.move_and_slide()


func exit():
	pass
	# Return to initial velocity
#	player.velocity.x = stored_velocity.x
#	player.velocity.z = stored_velocity.z
	

