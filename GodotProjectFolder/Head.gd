extends MeshInstance3D


var set_pos


# Called when the node enters the scene tree for the first time.
func _ready():
	set_pos = position
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var dir = owner.global_transform.basis.z
	var dir_2d = Vector2(dir.x, dir.z)
	var new_dir = get_viewport().get_camera_3d().global_transform.basis.z
	var new_dir_2d = Vector2(new_dir.x, new_dir.z)
	var diff = dir_2d.angle_to(new_dir_2d)
	var deg_diff = rad_to_deg(diff) * 0.98
	var deg_round_diff = round(deg_diff / 36) * 36
	print(round(deg_round_diff))
	position = set_pos
	match round(deg_round_diff):
		0.0: 
			mesh.material.albedo_texture.current_frame = 0
		1 * 36.0: 
			mesh.material.albedo_texture.current_frame = 1
		2 * 36.0: 
			mesh.material.albedo_texture.current_frame = 2
		3 * 36.0: 
			mesh.material.albedo_texture.current_frame = 3
		4 * 36.0: 
			mesh.material.albedo_texture.current_frame = 4
		-4 * 36.0: 
			mesh.material.albedo_texture.current_frame = 6
		-3 * 36.0: 
			mesh.material.albedo_texture.current_frame = 7
		-2 * 36.0: 
			mesh.material.albedo_texture.current_frame = 8
		-1 * 36.0: 
			mesh.material.albedo_texture.current_frame = 9
		
		_:
			mesh.material.albedo_texture.current_frame = 5




