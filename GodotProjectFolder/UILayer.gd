extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_transition_area_body_entered(body):
	if body is Player:
		var vignette = $Vignette as ColorRect
		var vignette_anim = $Vignette/AnimationPlayer as AnimationPlayer
		var cam = get_viewport().get_camera_3d()
		var player = get_parent().get_node("Player")
		
		cam.get_parent().following = false
		vignette.position = cam.unproject_position(player.global_position) - vignette.size / 2
		
		vignette_anim.play("Close")
		await vignette_anim.animation_finished
		#vignette_anim.play("Open")
