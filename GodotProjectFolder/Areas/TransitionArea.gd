extends Area3D


@export_file var file


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	if body is Player:
		
		var move_direction_3d = -$Arrow.global_transform.basis.z
		var move_direction_2d = Vector2(move_direction_3d.x, move_direction_3d.z)
		body.input_enabled = false
		body.is_immune = true
		body.relative_input_dir = move_direction_2d
		
		get_tree().root.get_node("Main").change_scene(file)
