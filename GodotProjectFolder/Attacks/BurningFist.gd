extends Node3D


var caster


# Called when the node enters the scene tree for the first time.
func _ready():
	$MeshInstance3D/AnimationPlayer.play("Spin")
	global_position = caster.global_position
	$Hitbox.caster = self.caster
	


func _physics_process(delta):
	global_position = caster.global_position
	#look_at(global_position + Vector3(-caster.facing_dir.x, 0, -caster.facing_dir.y))
	if caster.velocity.length() > 13:
		look_at(caster.global_position-caster.velocity)


func _on_animation_player_animation_finished(anim_name):
	queue_free()
