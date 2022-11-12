extends State


var player : Player

var attack_length = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	attack_length = 30
	var burst = load("res://Attacks/BurningFist.tscn").instantiate()
	burst.caster = player
	get_tree().root.add_child(burst)
	player.velocity = best_target()
	player.set_target_facing(Vector2(player.velocity.x, player.velocity.z))


func update(delta):
	pass


func physics_update(delta):
	
	player.anim.play("thrust")
	
	# Add the gravity
	#player.velocity.y -= player.GRAVITY * delta
	
#	var hor_velocity = Vector2(player.velocity.x, player.velocity.z).normalized()
#	hor_velocity *= attack_length
#	player.velocity.x = hor_velocity.x
#	player.velocity.z = hor_velocity.y
	player.velocity = player.velocity.normalized() * attack_length
	
	player.move_and_slide()
	
	if player.is_on_floor():
		attack_length -= 60 * delta
	else:
		attack_length -= 40 * delta
	
	if attack_length <= 5:
		state_machine.transition_to("Idle")


func exit():
	pass


func jump():
	player.velocity.y = player.JUMP_VELOCITY
	player.can_hold_jump = true
	state_machine.transition_to("InAir")


func best_target(aim_ahead = 0):
	var dist = 20
	var target_node = null
	var target_angle = Vector3(player.target_facing_dir.x, 0, player.target_facing_dir.y).normalized()
	for n in get_tree().get_nodes_in_group("enemies"): #change this to hurtbox
		
		var ppos = player.global_position
		var ppos2d = Vector2(ppos.x, ppos.z)
		var npos = n.global_position
		var npos2d = Vector2(npos.x, npos.z)
		
		var param := PhysicsRayQueryParameters3D.new()
		param.from = ppos
		param.to = npos
		param.collision_mask = 0b0001 #Bit mask for the first layer
		var space_state = player.get_world_3d().direct_space_state
		var result := space_state.intersect_ray(param)
		if result:
			# collision at ray point
			pass
		elif abs(ppos2d.direction_to(npos2d).angle_to(player.target_facing_dir.normalized())) < PI/3: # change to else to just target nearest enemy
		#else:
			var current_dist = ppos.distance_to(npos)
			if current_dist < dist:
				dist = current_dist
				target_node = n
				target_angle = ppos.direction_to(npos + n.velocity * aim_ahead)
	
	return target_angle
