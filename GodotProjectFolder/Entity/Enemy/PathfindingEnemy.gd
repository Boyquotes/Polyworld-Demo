class_name Enemy
extends PathfindingEntity


@export var can_jump = false

var player : Player
var rng = RandomNumberGenerator.new()


func _ready():
	super()
	player = get_parent().get_node("Player") as Player


func _process(_delta):
	pass


func _physics_process(_delta):
	pass


func is_instance_visible(instance):
	
	if !is_instance_valid(instance):
		return false
	
	var ppos = global_position
	var ppos2d = Vector2(ppos.x, ppos.z)
	var npos = instance.global_position
	var npos2d = Vector2(npos.x, npos.z)
	
	var param := PhysicsRayQueryParameters3D.new()
	param.from = ppos
	param.to = npos
	param.collision_mask = 0b0001 #Bit mask for the first layer
	var space_state =get_world_3d().direct_space_state
	var result := space_state.intersect_ray(param)
	
	var angle_difference = abs(ppos2d.direction_to(npos2d).angle_to(facing_dir_target.normalized()))
	
	if ppos.distance_to(npos) < 20:
		if result:
			# collision at ray point
			return false
		else:
			if angle_difference < PI/3:
				return true
		return false


func _on_entity_died():
	queue_free()


func _on_hurtbox_area_entered(hitbox : Hitbox):
	if hitbox.caster != self:
		if "contact" in hitbox.get_parent():
			hitbox.get_parent().contact()
		if hitbox.is_vessel:
			return
		take_damage(hitbox.damage)
		var impact_angle = hitbox.global_position.direction_to(global_position)
		velocity = Vector3(hitbox.push_force_horizontal * impact_angle.x, hitbox.push_force_vertical, hitbox.push_force_horizontal * impact_angle.z)
		$StateMachine.transition_to("Stunned")
