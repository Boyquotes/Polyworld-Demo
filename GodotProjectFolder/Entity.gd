class_name Entity
extends CharacterBody3D


@export var health = 100
@export var mass = 1

@export var move_speed := 12.0 #12
@export var move_accel := 60.0 # 60
@export var move_decel := 50.0 # 50 #replace this with a friction float that is multiplied with and stored in velocity depending on the group the colliding floor is in
@export var air_accel := 30.0
@export var turn_speed := 15.0
@export var jump_force := 15.0

const GRAVITY := 70.0
const HOLD_GRAVITY := 30.0

var facing_dir := Vector2.DOWN
var facing_dir_target := Vector2.DOWN


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_facing_target(dir:Vector2):
	if dir != Vector2.ZERO:
		facing_dir_target = dir.normalized()


func update_facing(delta):
	facing_dir = facing_dir.slerp(facing_dir_target, turn_speed * delta)
	rotation.y = -facing_dir.angle() + PI/2


func health_change(amount:=0):
	# Instantiate damage floater
	var floater = load("res://DamageFloater.tscn").instantiate()
	floater.text = str(amount)
	floater.hit_position = global_position
	get_tree().root.get_child(0).add_child(floater)
	
	#update health bar


func stun(dur:=0.0):
	pass


func die():
	queue_free()
