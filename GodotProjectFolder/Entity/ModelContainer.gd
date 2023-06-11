class_name ModelContainer
extends Node3D


var shake_intensity := 0.0:
	set(val):
		shake_intensity = clamp(val, 0, 10)
var shake_decay := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector3.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shake_intensity > 0:
		position = (Vector3(randf(), randf(), randf()) * 2 - Vector3.ONE) * shake_intensity
		shake_intensity *= shake_decay


func shake(intensity, decay):
	shake_intensity = intensity
	shake_decay = decay
