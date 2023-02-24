extends StaticBody3D

@export var speed = 0.8

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
		
		var collide = move_and_collide(velocity) as KinematicCollision3D

		if collide:
			contact()


# Called when the attack times out.
func _on_timer_timeout():
	contact()


# Response to making contact.
func contact():
	
	contacted = true
	
	var explosion = load("res://Attacks/Explosion.tscn").instantiate()
	explosion.global_position = global_position
	explosion.caster = caster
	get_tree().root.add_child(explosion)
	
	$Hitbox.set_deferred("monitorable", false)
	$GPUParticles3D.emitting = false
	await get_tree().create_timer(2, false).timeout
	queue_free()

