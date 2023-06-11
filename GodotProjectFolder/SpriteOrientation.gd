class_name SpriteOrientation
extends Sprite3D


@export var angle_count = 8
@export var is_rotating_clockwise = true
@export var x_coord := 0
@export var skip_others := false

var sprite_swap_angle


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	sprite_swap_angle = 360.0 / angle_count


# TODO : fix the fact that the back facing sprite is flipped horizontally

# Called every frame. '_delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	var dir = global_transform.basis.z
	var dir_2d = Vector2(dir.x, dir.z)
	var cam_dir = get_viewport().get_camera_3d().global_transform.basis.z
	var cam_dir_2d = Vector2(cam_dir.x, cam_dir.z)
	var diff = dir_2d.angle_to(cam_dir_2d)
	var deg_diff = rad_to_deg(diff)
	var deg_round_diff = round(deg_diff / sprite_swap_angle) * sprite_swap_angle
	var frame_number = int(fposmod(round(deg_round_diff / sprite_swap_angle), angle_count))
	
	if frame_number > angle_count / 2:
		frame_coords.y = abs(frame_number - angle_count)
		flip_h = !is_rotating_clockwise
	else:
		frame_coords.y = frame_number
		flip_h = is_rotating_clockwise
	
	if skip_others:
		frame_coords.y *= 2
	
	frame_coords.x = x_coord
