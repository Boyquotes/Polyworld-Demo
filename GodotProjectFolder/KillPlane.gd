extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_kill_plane_body_entered(body):
	body.global_position = Vector3(0,10,0)
	#body.global_position.y = 10
	

