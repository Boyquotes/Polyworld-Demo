class_name Entity
extends CharacterBody3D


signal entity_died


const GRAVITY := 70.0

@export var max_health := 50
@export var move_speed := 13.0
@export var move_accel := 70.0
@export var move_decel := 50.0 # 50 #TODO : replace this with a friction float that is multiplied with and stored in velocity depending on the group the colliding floor is in
@export var air_accel := 25.0
@export var turn_speed := 14.0
@export var jump_force := 15.0
@export var mass := 1.0

# TODO : is this a good method ?
var block_multiplier = 0

var health := max_health:
	set(val):
		if val <= 0: 
			val = 0
			emit_signal("entity_died")
		if val >= max_health:
			val = max_health
		health = val

@onready var facing_dir := Vector2(basis.z.x, basis.z.z)
@onready var facing_dir_target := Vector2(basis.z.x, basis.z.z):
	set(val):
		if val != Vector2.ZERO:
			facing_dir_target = val.normalized()


func face_toward(dest):
	var dest_2d = Vector2(dest.x, dest.z)
	var pos_2d = Vector2(global_position.x, global_position.z)
	facing_dir_target = pos_2d.direction_to(dest_2d)


func update_facing(_delta):
	# Update facing direction to turn towards target direction
	facing_dir = facing_dir.slerp(facing_dir_target, turn_speed * _delta)
	rotation.y = -facing_dir.angle() + PI/2
	#print(self)


# TODO : possibly add stun as another parameter, 0 would mean there is no stun
func take_damage(dmg:=0):
	dmg = dmg - dmg * block_multiplier
	
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


func heal(amt:=0):
	
	# Instantiate damage floater
	var floater = load("res://UI/DamageFloater.tscn").instantiate()
	floater.text = str(amt)
	floater.label_settings.font_color = Color.GREEN
	floater.hit_position = global_position
	get_tree().root.get_child(0).add_child(floater)
	
	# Decrease health
	health += amt
	
	# Update health bar
	var healthbar = get_node("HealthBar")
	if healthbar:
		healthbar.max_health = max_health
		healthbar.health = health


func is_instance_visible(instance):
	
	if !is_instance_valid(instance):
		return false
	
	var ppos = global_position
	var ppos2d = Vector2(ppos.x, ppos.z)
	var npos = instance.global_position
	var npos2d = Vector2(npos.x, npos.z)
	
	var param := PhysicsRayQueryParameters3D.new()
	param.from = ppos
	param.to = npos
	param.collision_mask = 0b0001 #Bit mask for the first layer
	var space_state =get_world_3d().direct_space_state
	var result := space_state.intersect_ray(param)
	
	var angle_difference = abs(ppos2d.direction_to(npos2d).angle_to(facing_dir.normalized()))
	
	if ppos.distance_to(npos) < 20:
		if result:
			# collision at ray point
			return false
		else:
			if angle_difference < PI/4:
				return true
		return false


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
