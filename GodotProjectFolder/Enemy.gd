extends CharacterBody3D


const GRAVITY := 40.0


var health = 100

var stunned = false
var alerted = false

@onready var anim = $Model/AnimationPlayer as AnimationPlayer


func _ready():
	alerted = false


func _physics_process(delta):
	
	# Add the gravity
	velocity.y -= GRAVITY * delta
	
	var hor_velocity = Vector2(velocity.x, velocity.z)
	
	if health > 0:
		look_at(Vector3(get_parent().get_node("Player").global_position.x, global_position.y, get_parent().get_node("Player").global_position.z))
		rotation.y += PI
		
		if is_on_floor():
			
			if global_position.distance_to(get_parent().get_node("Player").global_position) > 10:
				#RUN
				hor_velocity = hor_velocity.move_toward(Vector2(global_transform.basis.z.x, global_transform.basis.z.z) * 5, 0.5)
				anim.play("run")
				
			else:
				#IDLE
				hor_velocity *= 0.9
				anim.play("idle")
			
		else:
			anim.play("hurt")
	else:
		if is_on_floor():
			hor_velocity *= 0.9
			anim.play("fallen")
		else:
			anim.play("hurt")
	
	
	velocity.x = hor_velocity.x
	velocity.z = hor_velocity.y
	
	move_and_slide()


func hurt():
	anim.play("hurt", 0)
