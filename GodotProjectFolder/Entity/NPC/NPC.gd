extends CharacterBody3D


@onready var soft_collider = $SoftCollider as SoftCollider

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	velocity.y -= 70 * delta
	
	var hor_velocity = Vector2(velocity.x, velocity.z)
	hor_velocity = hor_velocity.move_toward(Vector2.ZERO, 50 * delta)
	
	velocity.x = hor_velocity.x
	velocity.z = hor_velocity.y
	
	var push_vector = soft_collider.get_push_vector()
	velocity.x += push_vector.x
	velocity.z += push_vector.y
	
	move_and_slide()
