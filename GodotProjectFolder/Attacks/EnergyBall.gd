extends Node3D


@export var speed = 0.5


var caster


var velocity = Vector3.ZERO
var direction = Vector3.ZERO
var targ = null

var contacted = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox.caster = self.caster
	global_position = caster.global_position
	
	targ = best_target(0.0)
	direction = global_position.direction_to(targ.global_position)
	
	velocity = direction * speed
	velocity.y += 0.2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	direction = global_position.direction_to(targ.global_position)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	global_position += velocity
	velocity.y -= 0.01
	
	if contacted:
		pass


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
	
	return target_node


func _on_timer_timeout():
	queue_free()


func contact():
	contacted = true
	queue_free()
