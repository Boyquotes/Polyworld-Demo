class_name PathfindingEntity
extends Entity


@export var should_avoid = true

var running = false # TODO : THIS IS TEMPORARY!! MAKE THIS USE A STATEMACHINE

var jump_thresh = 0.2

var agent : NavigationAgent3D


func _ready():
	agent = $NavigationAgent3D as NavigationAgent3D
	agent.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed)


func ai_move(_delta:float, destination:Vector3, min_range:=2.0, accel_by_distance:=false, can_hop=true, always_hop:=false, shortcut_bias:=2.0):
	
	# Subtract gravity from vertical velocity
	vert_velocity -= GRAVITY * _delta
	
	# Set the destination as the target location
	agent.target_position = destination
	
	var destination_2d = Vector2(destination.x, destination.z)
	var current_pos = global_transform.origin
	var current_pos_2d = Vector2(current_pos.x, current_pos.z)
	var direct_distance = current_pos.distance_to(destination)
	var direct_distance_2d = current_pos_2d.distance_to(destination_2d)
	var direction = current_pos_2d.direction_to(destination_2d)
	
	if direct_distance_2d > min_range:
		running = true
		if is_on_floor():
			
			var next_location = agent.get_next_path_position()
			var next_location_2d = Vector2(next_location.x, next_location.z)
			var final_location = agent.get_final_position()
			var path_length = 0
			
			# if final location is closer to destination than your current distance to destination,
			# meaning, you won't end up further away from destination if going to the final location
			if final_location.distance_to(destination) < direct_distance:
				direction = current_pos_2d.direction_to(next_location_2d)
				path_length = get_path_distance(agent.get_current_navigation_path())
			
			var at_end_of_path = path_length <= 1
			
			# If it has made it as close as possible to its destination, or if the path is much further 
			# than the direct distance, just jump in the target's direction instead of pathfinding
			if at_end_of_path || path_length > direct_distance * shortcut_bias:
				# TODO : figure out a way to account for destinations that are unreachable in general. Such as off the edge of a cliff
				direction = current_pos_2d.direction_to(destination_2d)
				if can_hop: #maybe move this out of the outer if statement to help if entity is stuck while pathfinding ?
					if (at_end_of_path && destination.y > current_pos.y + jump_thresh) || always_hop || is_on_wall():
						vert_velocity = jump_force
			
		if accel_by_distance:
			hor_velocity = hor_velocity.move_toward(direction * (move_speed + (agent.distance_to_target() - min_range) * 2), move_accel * _delta)
		else:
			if is_on_floor():
				hor_velocity = hor_velocity.move_toward(direction * move_speed, move_accel * _delta)
			else:
				hor_velocity = hor_velocity.move_toward(direction * move_speed, air_accel * _delta)
		
		facing_dir_target = hor_velocity.normalized()
		
	else:
		# Decelerate towards zero
		if is_on_floor():
			hor_velocity = hor_velocity.move_toward(Vector2.ZERO, move_decel * _delta)
		else:
			hor_velocity = hor_velocity.move_toward(Vector2.ZERO, air_accel * _delta)
		running = false
	
	# Handle soft collisions
	var soft_collider = get_node("SoftCollider")
	if soft_collider:
		hor_velocity += soft_collider.get_push_vector()
	
	# Set agent avoidance and move with new velicocity
	if is_on_floor() and should_avoid:
		agent.avoidance_enabled = true
		agent.max_speed = move_speed
		agent.set_velocity(Vector3(hor_velocity.x, vert_velocity, hor_velocity.y))
	else:
		agent.avoidance_enabled = false
		velocity = Vector3(hor_velocity.x, vert_velocity, hor_velocity.y)
		apply_velocities()


func get_path_distance(path:PackedVector3Array):
	var distance = 0
	for v in range(path.size()-1):
		distance += path[v].distance_to(path[v+1])
	return distance


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	hor_velocity = Vector2(safe_velocity.x, safe_velocity.z)
	vert_velocity = safe_velocity.y
	apply_velocities()
