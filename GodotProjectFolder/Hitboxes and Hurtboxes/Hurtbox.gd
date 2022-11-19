class_name Hurtbox
extends Area3D


@export var mass := 1.0

var is_stunned = false
var superguarding = false


func _ready():
	pass

func _process(delta):
	pass


func _on_hurtbox_area_entered(hitbox : Hitbox):
	
	if hitbox == null:
		print("ERROR: NOT A HITBOX")
		return
	
	if hitbox.caster == get_parent():
		return
	
	# Instantiate damage floater
	var floater = load("res://DamageFloater.tscn").instantiate()
	floater.text = str(hitbox.damage)
	floater.global_position = global_position
	get_tree().root.add_child(floater)
	
	hitbox.get_node("AudioStreamPlayer3D").play()
	
	# Change this to keep knockback information in the hitbox
	var dir = hitbox.global_position.direction_to(global_position)
	var knockback = Vector3(dir.x * hitbox.push_force_horizontal, 
							hitbox.push_force_vertical,
							dir.z * hitbox.push_force_horizontal)
	get_parent().velocity = knockback
	
	var lag_dur = hitbox.damage * 0.025
	
	screenshake(0.1)
	hitlag(hitbox, lag_dur)
	hurtlag(lag_dur)


func hitlag(hitbox:Hitbox, duration:float):
	
	var hitbox_parent = hitbox.get_parent()
	
	disable(hitbox_parent)
	if hitbox.lag_caster:
		disable(hitbox.caster)
	await get_tree().create_timer(duration).timeout
	if hitbox != null:
		enable(hitbox_parent)
		if hitbox_parent.has_method("contact"):
			hitbox_parent.contact()
		enable(hitbox.caster)


func hurtlag(duration:float):
	
	var lag_target = get_parent() # the hurtbox owner that is being lagged
	var shake_target = get_parent().find_child("Model") # the node being shaken
	
	var hurtshaker = load("res://Shaker.tscn").instantiate() as Shaker
	hurtshaker.initialize(1, 0.025)
	shake_target.add_child(hurtshaker)
	
	disable(lag_target)
	await get_tree().create_timer(duration).timeout
	if lag_target != null:
		enable(lag_target)
	if hurtshaker != null:
		hurtshaker.end_shake()


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


func screenshake(duration:float):
	var shake_target = get_viewport().get_camera_3d()
	var screenshaker = load("res://Shaker.tscn").instantiate() as Shaker
	screenshaker.initialize(0.75, 0.025)
	shake_target.add_child(screenshaker)
	await get_tree().create_timer(duration).timeout
	if screenshaker != null:
		screenshaker.end_shake()

