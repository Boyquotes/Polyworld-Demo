extends Node3D


var caster


# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox.caster = self.caster
	$GPUParticles3D.emitting = true


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_timer_timeout():
	$Hitbox.set_deferred("monitorable", false)
	await get_tree().create_timer(2, false).timeout
	queue_free()
