extends Node3D


@onready var anim = $AnimationPlayer as AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	anim.play("run")
	

func _physics_process(delta):
	global_position = global_position.move_toward(Vector3(get_parent().get_node("Player").global_position.x, global_position.y, get_parent().get_node("Player").global_position.z), 0.15)
	look_at(Vector3(get_parent().get_node("Player").global_position.x, global_position.y, get_parent().get_node("Player").global_position.z))
	rotation.y -= PI/2
