class_name Hitbox
extends Area3D


@export var lag_caster := true
@export var damage := 1.0
@export var push_force_horizontal := 1.0
@export var push_force_vertical := 1.0
@export var can_burn := false

var hit_list = []
var push_direction : Vector2
var caster = null

@onready var stream_player = $AudioStreamPlayer3D as AudioStreamPlayer3D


# Recursively disable all children
func disable(entity):
	if entity == null:
		return
	entity.set_process(false)
	entity.set_physics_process(false)
	entity.set_process_internal(false)
	entity.set_physics_process_internal(false)
	for child in entity.get_children():
		if child is Shaker:
			break
		if child is AudioStreamPlayer3D:
			break
		if child is AnimationPlayer:
			break
		disable(child)


# Recursively enable all children
func enable(entity):
	if entity == null:
		return
	entity.set_process(true)
	entity.set_physics_process(true)
	entity.set_process_internal(true)
	entity.set_physics_process_internal(true)
	for child in entity.get_children():
		if child is Shaker:
			break
		if child is AudioStreamPlayer3D:
			break
		enable(child)
