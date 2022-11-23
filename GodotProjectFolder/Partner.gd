class_name Partner
extends PathfindingEntity


@export var weight = 2.0

var player : Player
var rng = RandomNumberGenerator.new()


func _ready():
	super()
	player = get_parent().get_node("Player") as Player


func _process(delta):
	#attacking(player)
	pass


func _physics_process(delta):
	
	ai_move(delta, player.global_position, 3.0, true)
	if velocity != Vector3.ZERO:
		look_at(global_position + velocity)
		rotation.x = 0
		rotation.z = 0
	
	if global_position.distance_to(player.global_position) > 15:
		global_position = player.global_position + Vector3.UP * 5


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
#	var missile_scene = load("res://Fireball.tscn")
#	var missile = missile_scene.instsantiate()
#	missile.direction = target_angle
#	missile.global_transform.origin = global_transform.origin
#
#	get_tree().get_root().add_child(missile)
#	missile.get_node("Hitbox").caster = self
