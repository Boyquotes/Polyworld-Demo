class_name Enemy
extends PathfindingEntity


@export var can_jump = false

var player : Player
var rng = RandomNumberGenerator.new()


func _ready():
	super()
	player = get_parent().get_node("Player") as Player


func _process(delta):
	pass


func _physics_process(delta):
	pass


func attacking(target):

	var dist = 20
	var aim_ahead = 0.35

	var can_shoot = false
	var ppos = global_transform.origin
	var npos = target.global_transform.origin
	
	var target_angle = ppos.direction_to(npos)
	
	var param := PhysicsRayQueryParameters3D.new()
	param.from = ppos
	param.to = npos
	param.collision_mask = 0b0001 #Bit mask for the first layer
	var space_state = get_world_3d().direct_space_state
	var result := space_state.intersect_ray(param)
	if result:
		# collision at ray point
		pass
	else:
		can_shoot = true
		#target_angle = ppos.direction_to(npos + target.velocity * aim_ahead * ppos.distance_to(npos) * 0.08)
		target_angle = ppos.direction_to(npos)
	
	if can_shoot:
		rng.randomize()
		var my_random_number = rng.randi_range(0, 100)
		if my_random_number < 1:
			shoot(target_angle)


func shoot(target_angle):
	pass


func stun(dur = 2):
	$StateMachine/Stunned.stun_duration = dur
	$StateMachine.transition_to("Stunned")


func is_player_visible(aim_ahead = 0):
	var dist = 20
	var target_node = null
	var target_angle = Vector3(facing_dir.x, 0, facing_dir.y).normalized()
	var ppos = global_position
	var ppos2d = Vector2(ppos.x, ppos.z)
	var npos = player.global_position
	var npos2d = Vector2(npos.x, npos.z)
	
	var param := PhysicsRayQueryParameters3D.new()
	param.from = ppos
	param.to = npos
	param.collision_mask = 0b0001 #Bit mask for the first layer
	var space_state =get_world_3d().direct_space_state
	var result := space_state.intersect_ray(param)
	
	var angle_difference = abs(ppos2d.direction_to(npos2d).angle_to(facing_dir_target.normalized()))
	
	if result:
		# collision at ray point
		return false
	else:
		if angle_difference < PI/3:
			return true
	return false


func _on_entity_died():
	die()


func _on_hurtbox_area_entered(hitbox : Hitbox):
	if hitbox.caster != self:
		if "contact" in hitbox.get_parent():
			hitbox.get_parent().contact()
		take_damage(hitbox.damage)
		var impact_angle = hitbox.global_position.direction_to(global_position)
		velocity = Vector3(hitbox.push_force_horizontal * impact_angle.x, hitbox.push_force_vertical, hitbox.push_force_horizontal * impact_angle.z)
		$StateMachine.transition_to("Stunned")
