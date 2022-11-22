extends State


var player : Player

var attack_length = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	attack_length = 10
	var best_targ = best_target()
	
	var ball = load("res://Attacks/Grabber.tscn").instantiate()
	ball.caster = player
	ball.direction = Vector3(best_targ.x, 0, best_targ.z)
	get_tree().root.add_child(ball)
	ball.global_position = player.global_position
	
	
	player.set_target_facing(Vector2(best_targ.x, best_targ.z))
	
	print(best_targ)
	
	player.velocity.y = 15
	


func update(delta):
	pass


func physics_update(delta):
	
	player.anim.play("thrust")
	
	# Add the gravity
	#player.velocity.y -= player.GRAVITY * delta
	
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	#hor_velocity = hor_velocity.normalized() * attack_length
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	player.move_and_slide()
	
	if player.is_on_floor():
		attack_length -= 60 * delta
	else:
		attack_length -= 40 * delta
	
	if attack_length <= 5:
		if player.is_on_floor():
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("InAir")
			state_machine.get_node("InAir").flipping = true


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
		elif abs(ppos2d.direction_to(npos2d).angle_to(player.target_facing_dir.normalized())) < PI/4: # change to else to just target nearest enemy
		#else:
			var current_dist = ppos.distance_to(npos)
			if current_dist < dist:
				dist = current_dist
				target_node = n
				target_angle = ppos.direction_to(npos + n.velocity * aim_ahead)
	
	return target_angle
