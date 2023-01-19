class_name Entity
extends CharacterBody3D


signal entity_died


const GRAVITY := 70.0

@export var max_health := 50
@export var move_speed := 12.0
@export var move_accel := 60.0
@export var move_decel := 50.0 # 50 #replace this with a friction float that is multiplied with and stored in velocity depending on the group the colliding floor is in
@export var air_accel := 25.0
@export var turn_speed := 15.0
@export var jump_force := 15.0
@export var mass := 1.0

var health := max_health:
	set(val):
		if val <= 0: 
			val = 0
			emit_signal("entity_died")
		health = val
	get:
		return health

var facing_dir := Vector2.DOWN
@onready var facing_dir_target := Vector2(basis.z.x, basis.z.z):
	set(val):
		if val != Vector2.ZERO:
			facing_dir_target = val.normalized()
	get:
		return facing_dir_target


func face_toward(dest):
	var dest_2d = Vector2(dest.x, dest.z)
	var pos_2d = Vector2(global_position.x, global_position.z)
	facing_dir_target = pos_2d.direction_to(dest_2d)


func update_facing(_delta):
	# Update facing direction to turn towards target direction
	facing_dir = facing_dir.slerp(facing_dir_target, turn_speed * _delta)
	rotation.y = -facing_dir.angle() + PI/2


func take_damage(dmg:=0):
	# Instantiate damage floater
	var floater = load("res://UI/DamageFloater.tscn").instantiate()
	floater.text = str(dmg)
	floater.hit_position = global_position
	get_tree().root.get_child(0).add_child(floater)
	
	# Decrease health
	health -= dmg
	
	# Update health bar
	var healthbar = get_node("HealthBar")
	if healthbar:
		healthbar.max_health = max_health
		healthbar.health = health


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
