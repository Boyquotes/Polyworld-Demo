class_name Enemy
extends PathfindingEntity


@export var health = 0.0
@export var weight = 2.0
@export var can_jump = false

var player : Player
var rng = RandomNumberGenerator.new()

var stunned = false
@onready var stun_timer = $StunTimer as Timer


func _ready():
	super()
	player = get_parent().get_node("Player") as Player


func _process(delta):
	if health <= 0:
		queue_free()
	attacking(player)


func _physics_process(delta):
	
	if not stunned:
		$MeshInstance3D2.visible = false
		ai_move(delta, player.global_position, 6.0, false, can_jump)
		if velocity != Vector3.ZERO:
			look_at(global_position + velocity)
			rotation.x = 0
			rotation.z = 0
		else:
			look_at(player.global_position)
			rotation.x = 0
			rotation.z = 0
	else:
		$MeshInstance3D2.visible = true
		velocity.y -= gravity * delta
		if is_on_floor():
			var hor_velocity = Vector2(velocity.x, velocity.z)
			hor_velocity = hor_velocity.move_toward(Vector2.ZERO, move_decel * delta)
			velocity.x = hor_velocity.x
			velocity.z = hor_velocity.y
		move_and_slide()


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


func stun(dur = 2):
	stunned = true
	stun_timer.start(dur)
	await stun_timer.timeout
	stunned = false
	
