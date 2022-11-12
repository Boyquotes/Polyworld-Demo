extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready():
	set_timer(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.y += 2 * delta


func set_timer(duration : float):
	await get_tree().create_timer(duration).timeout
	queue_free()
