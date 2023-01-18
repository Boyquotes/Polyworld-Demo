extends Node3D


@export var speed = 0.5


var caster


var velocity = Vector3.ZERO
var direction = Vector3.ZERO

var contacted = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox.caster = self.caster
	global_position = caster.global_position
	velocity = Vector3(direction.x, 0, direction.y) * speed

	velocity = direction * speed


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _physics_process(_delta):
	global_position += velocity
	
	if contacted:
		velocity = global_position.direction_to(caster.global_position) * 0.5
		if global_position.distance_to(caster.global_position) < 0.6:
			queue_free()


func _on_timer_timeout():
	queue_free()


func contact():
	caster.velocity = direction.normalized() * 15
	contacted = true
	# FIX THIS
	$Hitbox.monitoring = false
	$Hitbox.monitorable = false
