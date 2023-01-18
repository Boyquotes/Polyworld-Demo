class_name CameraRegion
extends Area3D


@export var x_rotation = -PI/9
@export var y_rotation = 0.0

@onready var camera_arm = get_viewport().get_camera_3d().get_parent() as CameraArm


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	if body is Player:
		camera_arm.set_rotation_target(Vector3(x_rotation, y_rotation, 0))
	
