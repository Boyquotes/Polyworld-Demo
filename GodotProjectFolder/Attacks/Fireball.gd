extends StaticBody3D


@export var speed = 0.0


var caster


const GRAVITY = 1.0

var direction = Vector3.ZERO
var velocity = Vector3.ZERO


func _ready():
	$Hitbox.caster = self.caster
	global_position = caster.global_position
	velocity = Vector3(direction.x, 0, direction.y) * speed
	#screenshake(0.1)
	
	var best_targ = best_target(0.0)
	#best_targ = caster.target_facing_dir
	#direction = direction.slerp(Vector2(best_targ.x, best_targ.y), 0.5)
	direction = best_targ
	#velocity = Vector3(direction.x, 0, direction.y) * speed
	velocity = direction * speed


func _physics_process(delta):
	
	velocity.y -= GRAVITY * delta

	var collide = move_and_collide(velocity) as KinematicCollision3D

	if collide:
		
		
		var collision_angle = collide.get_angle()
		if collision_angle < PI/4: # floor collision
			
			var best_targ = best_target(0.0)
			#direction = direction.slerp(Vector2(best_targ.x, best_targ.y), 0.8)
			direction = best_targ
			
			#velocity = Vector3(direction.x, velocity.y, direction.y) * speed
			
			var hor_velocity = Vector3(direction.x, 0, direction.z).normalized() * speed
			hor_velocity = hor_velocity.slide(collide.get_normal())
			
			velocity.x = hor_velocity.x
			velocity.z = hor_velocity.z
			
			if Vector3(collide.get_normal().x, 0, collide.get_normal().z).normalized().angle_to(hor_velocity) > PI/4:
				velocity.y = 0.2 / collide.get_normal().y
			else:
				velocity.y = 0.2 * collide.get_normal().y
		else: # wall collision
			contact()
			# or bounce (OPTIONAL)
			var hor_velocity = Vector3(velocity.x, 0, velocity.z).normalized() * speed
			hor_velocity = hor_velocity.bounce(Vector3(collide.get_normal().x, 0, collide.get_normal().z).normalized())
			velocity.x = hor_velocity.x
			velocity.y = 0
			velocity.z = hor_velocity.z


func _on_timer_timeout():
	contact()


func _on_hitbox_area_entered(area):
	pass


func screenshake(duration:float):
	var shake_target = get_viewport().get_camera_3d()
	var screenshaker = load("res://Shaker.tscn").instantiate() as Shaker
	screenshaker.initialize(0.75, 0.025)
	shake_target.add_child(screenshaker)
	await get_tree().create_timer(duration).timeout
	screenshaker.end_shake()


func best_target(aim_ahead = 0):
	var dist = 20
	var target_node = null
	var target_angle = direction.normalized()
	for n in get_tree().get_nodes_in_group("enemies"): #change this to hurtbox
		
		var ppos = global_position
		var ppos2d = Vector2(ppos.x, ppos.z)
		var npos = n.global_position
		var npos2d = Vector2(npos.x, npos.z)
		
		var param := PhysicsRayQueryParameters3D.new()
		param.from = ppos
		param.to = npos
		param.collision_mask = 0b0001 #Bit mask for the first layer
		var space_state = get_world_3d().direct_space_state
		var result := space_state.intersect_ray(param)
		if result:
			# collision at ray point
			pass
		elif abs(ppos2d.direction_to(npos2d).angle_to(Vector2(direction.x, direction.z).normalized())) < PI/3: # change to else to just target nearest enemy
		#else:
			var current_dist = ppos.distance_to(npos)
			if current_dist < dist:
				dist = current_dist
				target_node = n
				target_angle = ppos.direction_to(npos + n.velocity * aim_ahead)
	
	return target_angle


func contact():
	
	var explosion = load("res://Attacks/Explosion.tscn").instantiate()
	explosion.global_position = global_position
	explosion.caster = caster
	get_tree().root.add_child(explosion)
	queue_free()
	
	

