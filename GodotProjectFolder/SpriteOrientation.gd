extends Sprite3D


@export var angle_count = 10
@export var is_rotating_clockwise = true
@export var x_coord := 0

var sprite_swap_angle


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_swap_angle = 360.0 / angle_count


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	var dir = get_parent().global_transform.basis.z
	var dir_2d = Vector2(dir.x, dir.z)
	var new_dir = get_viewport().get_camera_3d().global_transform.basis.z
	var new_dir_2d = Vector2(new_dir.x, new_dir.z)
	var diff = dir_2d.angle_to(new_dir_2d)
	var deg_diff = rad_to_deg(diff) * 0.95
	var deg_round_diff = round(deg_diff / sprite_swap_angle) * sprite_swap_angle
	var frame_number = int(fposmod(round(deg_round_diff / sprite_swap_angle), angle_count))
	
	
	if posmod(frame_number / (vframes-1), 2) == 0:
		frame_coords.y = frame_number
		flip_h = false
	else:
		frame_coords.y = (vframes-1) - posmod(frame_number, (vframes-1))
		flip_h = true
	
	if is_rotating_clockwise:
		if frame_coords.y > 0 and frame_coords.y < vframes-1:
			flip_h = !flip_h
	
	frame_coords.x = x_coord
