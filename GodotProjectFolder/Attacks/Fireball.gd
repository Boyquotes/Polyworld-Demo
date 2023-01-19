extends StaticBody3D


@export var speed = 0.0


var caster


const GRAVITY = 1.0

var direction := Vector3.ZERO
var velocity := Vector3.ZERO
var contacted := false


func _ready():
	$Hitbox.caster = self.caster
	global_position = caster.global_position
	velocity = Vector3(direction.x, 0, direction.y) * speed
	
	velocity = direction * speed

func _physics_process(_delta):
	
	velocity.y -= GRAVITY * _delta

	var collide = move_and_collide(velocity) as KinematicCollision3D

	if collide:
		
		var collision_angle = collide.get_angle()
		if collision_angle < PI/4: # floor collision
			
			#direction = direction.slerp(Vector2(best_targ.x, best_targ.y), 0.8)
			# direction = best_targ
			
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


func contact():
	contacted = true
	var explosion = load("res://Attacks/Explosion.tscn").instantiate()
	explosion.global_position = global_position
	explosion.caster = caster
	get_tree().root.add_child(explosion)
	queue_free()

