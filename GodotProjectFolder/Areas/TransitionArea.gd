extends Area3D


@export_file var file
@export var id = 0
@export var exit_id = 1

var entering = false

@onready var arrow_direction = -$Arrow.global_transform.basis.z
@onready var spawn_position = $CollisionShape3D.global_position + arrow_direction * ($CollisionShape3D.shape.size.z/2)
@onready var exit_position = $CollisionShape3D.global_position - arrow_direction * ($CollisionShape3D.shape.size.z/2)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	if body is Player:
		body.input_enabled = false
		body.is_immune = true
		if entering: # If entering a scene
			body.relative_input_dir = Vector2(-arrow_direction.x, -arrow_direction.z)
		else:
			body.relative_input_dir = Vector2(arrow_direction.x, arrow_direction.z)
			get_tree().root.get_node("Main").change_scene(file, exit_id)


func _on_body_exited(body):
	if body is Player:
		if entering:
			body.input_enabled = true
			body.is_immune = false
			entering = false
			get_viewport().get_camera_3d().get_parent().following = true
