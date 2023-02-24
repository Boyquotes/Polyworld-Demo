extends State


var player : Player

var state_name = "Melee"


var stored_velocity : Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	
	# Store initial velocity
	stored_velocity = player.velocity
	
	# Rotate toward target
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	
	# Wait a second
	await get_tree().create_timer(0.15).timeout
	player.velocity.x += player.facing_dir_target.x * 2
	player.velocity.z += player.facing_dir_target.y * 2
	
	# Play correct animation
	player.anim.play("thrust", 0)
	
	# Spawn attack
	var hitbox = load("res://Hitboxes and Hurtboxes/Hitbox.tscn").instantiate() as Hitbox
	hitbox.damage = 8
	hitbox.caster = player
	hitbox.push_force_horizontal = 10
	hitbox.push_force_vertical = 10
	hitbox.push_direction = player.facing_dir
	var collisionshape = SphereShape3D.new()
	collisionshape.radius = 1
	hitbox.get_node("CollisionShape3d").shape = collisionshape
	get_tree().root.add_child(hitbox)
	hitbox.global_position = player.global_position + player.basis.z
	
	print(hitbox.global_position)
	
	# Wait a second
	await get_tree().create_timer(0.2).timeout
	
	hitbox.queue_free()
	
	# Return to standard state
	if player.is_on_floor():
		state_machine.transition_to("Grounded")
	else:
		state_machine.transition_to("InAir")
	


func update(_delta):
	pass


func physics_update(_delta):
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * _delta
	
	# Slow down the player
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	# hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * 0.5 * _delta)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	player.move_and_slide()


func exit():
	
	# Return to initial velocity
	player.velocity.x = stored_velocity.x
	player.velocity.z = stored_velocity.z
	

