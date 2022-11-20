extends Node3D


@onready var card_left = $UILayer/CardHolder/CardL as ColorRect
@onready var card_right = $UILayer/CardHolder/CardR as ColorRect
@onready var health_bar = $UILayer/HealthBar as ColorRect

@onready var card_left_cooldown = card_left.get_node("Cooldown")
@onready var card_right_cooldown = card_right.get_node("Cooldown")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var player = get_child(1).get_node("Player") as Player
	
	card_left.size.y = (1 - card_left_cooldown.time_left / card_left_cooldown.wait_time) * 42
	card_left.position.y = 258 - card_left.size.y
	
	card_right.size.y = (1 - card_right_cooldown.time_left / card_right_cooldown.wait_time) * 42
	card_right.position.y = 258 - card_right.size.y
	
	if card_left_cooldown.time_left == 0:
		player.is_left_cooling = false
		card_left.color.a = 0.9
	else:
		player.is_left_cooling = true
		card_left.color.a = 0.25
		
	if card_right_cooldown.time_left == 0:
		player.is_right_cooling = false
		card_right.color.a = 0.9
	else:
		player.is_right_cooling = true
		card_right.color.a = 0.25



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
