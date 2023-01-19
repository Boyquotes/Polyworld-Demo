class_name Hitbox
extends Area3D


@export var lag_caster := true
@export var is_vessel := false
@export var damage := 1
@export var push_force_horizontal := 1.0
@export var push_force_vertical := 1.0
@export var can_burn := false

var hit_list = []
var push_direction : Vector2
var caster = null

@onready var stream_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
