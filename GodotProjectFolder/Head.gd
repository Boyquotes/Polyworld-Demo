extends MeshInstance3D


var frame_count
var sprite_swap_angle


# Called when the node enters the scene tree for the first time.
func _ready():
	frame_count = mesh.material.get_shader_parameter("texture_albedo").frames	
	sprite_swap_angle = 360.0 / frame_count
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	
	
	var dir = get_parent().global_transform.basis.z
	var dir_2d = Vector2(dir.x, dir.z)
	var new_dir = get_viewport().get_camera_3d().global_transform.basis.z
	var new_dir_2d = Vector2(new_dir.x, new_dir.z)
	var diff = dir_2d.angle_to(new_dir_2d)
	var deg_diff = rad_to_deg(diff) * 0.95
	var deg_round_diff = round(deg_diff / sprite_swap_angle) * sprite_swap_angle
	var frame_number = fposmod(round(deg_round_diff / sprite_swap_angle), frame_count)
	mesh.material.get_shader_parameter("texture_albedo").current_frame = frame_number

