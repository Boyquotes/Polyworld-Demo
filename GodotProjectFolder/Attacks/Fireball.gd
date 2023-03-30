extends StaticBody3D


const GRAVITY = 1.0

@export var speed = 0.4

var caster

var direction := Vector3.ZERO
var velocity := Vector3.ZERO
var contacted := false


# TODO : make framerate independent

# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox.caster = self.caster
	global_position = caster.global_position
	velocity = direction * speed


# Called every physics frame. '_delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	if !contacted:
		velocity.y -= GRAVITY * _delta

		var collide = move_and_collide(velocity) as KinematicCollision3D

		if collide:
			
			var collision_angle = collide.get_angle()
			if collision_angle < PI/4: # floor collision
				
				var hor_velocity = Vector3(direction.x, 0, direction.z).normalized() * speed
				hor_velocity = hor_velocity.slide(collide.get_normal())
				
				velocity.x = hor_velocity.x
				velocity.z = hor_velocity.z
				
				if Vector3(collide.get_normal().x, 0, collide.get_normal().z).normalized().angle_to(hor_velocity) > PI/4:
					velocity.y = 0.22 / collide.get_normal().y
				else:
					velocity.y = 0.22 * collide.get_normal().y
			else: # wall collision
				contact()
				# or bounce (OPTIONAL)
				var hor_velocity = Vector3(velocity.x, 0, velocity.z).normalized() * speed
				velocity = hor_velocity.bounce(Vector3(collide.get_normal().x, 0, collide.get_normal().z).normalized())


# Called when the attack times out.
func _on_timer_timeout():
	contact()


# Response to making contact.
func contact():
	if !contacted:
		contacted = true
		
		var explosion = load("res://Attacks/Explosion.tscn").instantiate()
		explosion.global_position = global_position
		explosion.caster = caster
		get_tree().root.add_child(explosion)
		
		$Hitbox.set_deferred("monitorable", false)
		$GPUParticles3D.emitting = false
		$Shadow.queue_free()
		await get_tree().create_timer(2, false).timeout
		queue_free()

