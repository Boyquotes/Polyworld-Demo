extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func change_scene(scene_name : String):
	
	
	var vignette = $UILayer/Vignette as ColorRect
	var vignette_anim = $UILayer/Vignette/AnimationPlayer as AnimationPlayer
	var cam = get_viewport().get_camera_3d()
	var player = get_child(1).get_node("Player")
	
	cam.get_parent().following = false
	vignette.position = cam.unproject_position(player.global_position) - vignette.size / 2
	
	vignette_anim.play("Close")
	await vignette_anim.animation_finished
	
	get_child(1).free()
	var scene = load(scene_name).instantiate()
	add_child(scene)
	
	vignette = $UILayer/Vignette as ColorRect
	vignette_anim = $UILayer/Vignette/AnimationPlayer as AnimationPlayer
	cam = get_viewport().get_camera_3d()
	player = get_child(1).get_node("Player")
	cam.get_parent().global_position = player.global_position
	vignette.position = cam.unproject_position(player.global_position) - vignette.size / 2
	vignette.position = vignette.position.clamp(-vignette.size / 2 + Vector2(16, 16), vignette.size / 2 - Vector2(16, 16))
	await get_tree().create_timer(0.4).timeout
	
	vignette_anim.play("Open")
