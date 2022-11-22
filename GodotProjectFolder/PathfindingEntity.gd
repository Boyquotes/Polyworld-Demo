class_name PathfindingEntity
extends CharacterBody3D


@export var move_speed := 12.0
@export var move_accel := 60.0
@export var move_decel := 50.0
@export var jump_velocity := 15.0
@export var gravity := 40.0

var jump_thresh = 0.2
var shortcut_bias = 2

var agent : NavigationAgent3D


func _ready():
	agent = get_node("NavigationAgent3D") as NavigationAgent3D
	agent.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed)


func ai_move(delta:float, destination:Vector3, min_range:=2.0, accel_by_distance:=false, can_hop=true, always_hop:=false, shortcut_bias:=2.0):
	
	# Store horizontal velocity
	var hor_velocity = Vector2(velocity.x, velocity.z)
	# Store vertical velocity
	var vert_velocity = velocity.y
	
	# Add the gravity
	vert_velocity -= gravity * delta
	agent.set_target_location(destination)
	
	var destination_2d = Vector2(destination.x, destination.z)
	var current_pos = global_transform.origin
	var current_pos_2d = Vector2(current_pos.x, current_pos.z)
	var distance = current_pos.distance_to(destination)
	var distance_2d = current_pos_2d.distance_to(destination_2d)
	var direction = current_pos_2d.direction_to(destination_2d)
		
	if distance_2d > min_range:
		if is_on_floor():
			var next_location = agent.get_next_location()
			var next_location_2d = Vector2(next_location.x, next_location.z)
			var final_location = agent.get_final_location()
			var path_length = 0
			
			# if final location is closer to destination than your current distance
			if final_location.distance_to(destination) < current_pos.distance_to(destination):
				direction = current_pos_2d.direction_to(next_location_2d)
				path_length = get_path_distance(agent.get_nav_path())
			
			# If it has made it as close as possible to its destination, or if the path is much further 
			# than the direct distance, just jump in the target's direction instead of pathfinding
			if path_length <= 1 || path_length > agent.distance_to_target() * shortcut_bias:
				direction = current_pos_2d.direction_to(destination_2d)
				if can_hop: #maybe move this out of the outer if statement to help if entity is stuck while pathfinding ?
					if (path_length <= 1 && destination.y > current_pos.y + jump_thresh) || always_hop || is_on_wall():
						vert_velocity = jump_velocity
		
		if accel_by_distance:
			hor_velocity = hor_velocity.move_toward(direction * (move_speed + (agent.distance_to_target() - min_range) * 2), move_accel * delta)
		else:
			hor_velocity = hor_velocity.move_toward(direction * move_speed, move_accel * delta)
	else:
		# Decelerate towards zero
		if is_on_floor():
			hor_velocity = hor_velocity.move_toward(Vector2.ZERO, move_decel * delta)
		else:
			hor_velocity = hor_velocity.move_toward(direction * move_speed * 0.5, move_decel * delta)
			
	# Set new velocity and move
	if agent.avoidance_enabled:
		agent.max_speed = move_speed
		agent.set_velocity(Vector3(hor_velocity.x, vert_velocity, hor_velocity.y))
	else:
		velocity = Vector3(hor_velocity.x, vert_velocity, hor_velocity.y)
		move_and_slide()


func get_path_distance(path:PackedVector3Array):
	var distance = 0
	for v in range(path.size()-1):
		distance += path[v].distance_to(path[v+1])
	return distance


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
