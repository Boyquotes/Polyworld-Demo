extends Area3D


@export_file var file


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body is Player:
		get_parent().get_parent().get_parent().get_parent().change_scene(file)
