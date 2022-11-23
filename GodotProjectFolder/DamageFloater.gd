extends Label

var hit_position = Vector3.ZERO
var height = 0
var upward_speed = 35

# Called when the node enters the scene tree for the first time.
func _ready():
	set_timer(1)
	height = 0
	position = get_viewport().get_camera_3d().unproject_position(hit_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_viewport().get_camera_3d().unproject_position(hit_position)
	position.y -= height
	height += upward_speed * delta
	position = position.round()


func set_timer(duration : float):
	await get_tree().create_timer(duration).timeout
	queue_free()
