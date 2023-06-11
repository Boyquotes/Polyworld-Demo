extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var scene = load("res://Worlds/TestWorld.tscn").instantiate()
	add_child(scene)


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	# MENU RELATED STUFF
	if Input.is_action_just_pressed("menu"):
		get_tree().paused = !get_tree().paused


func change_scene(scene_name : String, exit_id = -1):
	
	var vignette = $UILayer/Vignette as ColorRect
	var vignette_anim = $UILayer/Vignette/AnimationPlayer as AnimationPlayer
	var cam = get_viewport().get_camera_3d()
	var player = get_child(1).get_node("Player")
	
	vignette.visible = true
	cam.get_parent().following = false
	vignette.position = cam.unproject_position(player.global_position) - vignette.size / 2
	
	vignette_anim.play("Close")
	await vignette_anim.animation_finished
	await get_tree().create_timer(0.1).timeout
	
	get_child(1).free()
	var scene = load(scene_name).instantiate()
	add_child(scene)
	
	cam = get_viewport().get_camera_3d()
	player = get_child(1).get_node("Player")
	
	# TODO : this system is so messy. I need to optimize scene transitions
	if exit_id != -1:
		var transition_areas = get_tree().get_nodes_in_group("transition_areas")
		for area in transition_areas:
			if area.id == exit_id:
				area.entering = true
				player.global_position = area.spawn_position
				#cam.get_parent().following = false
				#cam.get_parent().global_position = area.exit_position
				cam.get_parent().global_position = player.global_position
	else:
		player.global_position = Vector3(0,0,0)
		cam.get_parent().global_position = player.global_position
	
	vignette.position = cam.unproject_position(player.global_position) - vignette.size / 2
	vignette.position = vignette.position.clamp(-vignette.size / 2 + Vector2(16, 16), vignette.size / 2 - Vector2(16, 16))
	vignette_anim.play("Open")
