class_name Hurtbox
extends Area3D


@export var mass := 1.0
@export var shake_target : Node3D

var superguarding = false


@onready var stream_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
@onready var lag_timer = $LagTimer as Timer


func _ready():
	if get_parent().has_node("Model"):
		shake_target = get_parent().get_node("Model")


func _process(delta):
	pass


func _on_hurtbox_area_entered(hitbox : Hitbox):
	
	# Catch exceptions
	if hitbox == null:
		print("ERROR: NOT A HITBOX")
		return
	if hitbox.caster == get_parent():
		return
	
	# Add to a hit list to prevent double hitting
	if hitbox.hit_list.has(self):
		return
	else:
		hitbox.hit_list.append(self)
	
	# Don't get hit if superguarding
	if superguarding:
		return
	
	get_parent().health_change(hitbox.damage)
	
	# Set knockback
	if "velocity" in get_parent():
		var dir = hitbox.global_position.direction_to(global_position).normalized()
		var knockback = Vector3(dir.x * hitbox.push_force_horizontal, 
								hitbox.push_force_vertical,
								dir.z * hitbox.push_force_horizontal)
		get_parent().velocity = knockback
	
	# Set stun
	if get_parent().has_method("stun"):
		get_parent().stun(60)
	
	# Shake the screen
	screenshake(0.15)
	
	# Start lag timers
	var lag_dur = hitbox.damage * 0.025
	lag_timer.stop()
	lag_timer.start(lag_dur)
	
	# Hitlag and hurtlag
	#hitlag(hitbox)
	#hurtlag()


func hitlag(hitbox : Hitbox):
	
	var hitbox_parent = hitbox.get_parent()
	var hitbox_caster = hitbox.caster
	
	# put the audiostreamplayer in the attack scene not the hitbox scene, and activate it in the contact function ?
	if hitbox_parent.has_method("contact"):
		if "contacted" in hitbox_parent:
			if not hitbox_parent.contacted:
				hitbox_parent.contact()
	hitbox.stream_player.play()
	
	#disable(hitbox_parent)
	if hitbox.lag_caster:
		#disable(hitbox.caster)
		pass
	
	await lag_timer.timeout
	
	if hitbox != null:
		enable(hitbox_parent)
		if hitbox.lag_caster:
			enable(hitbox_caster)
	


func hurtlag():
	
	var hurtbox_parent = get_parent()
	
	# Hurtshake (the way shaking works can almost certainly be optimized)
	var hurtshaker = load("res://Shaker.tscn").instantiate() as Shaker
	hurtshaker.initialize(1, 0.025)
	shake_target.add_child(hurtshaker)
	
	# Hurtlag
	if hurtbox_parent.has_method("hurt"):
		hurtbox_parent.hurt()
	#disable(hurtbox_parent)
	
	await lag_timer.timeout
	
	if hurtbox_parent != null:
		enable(hurtbox_parent)
		
	for child in shake_target.get_children():
		if child is Shaker:
			child.end_shake()


func screenshake(duration:float):
	var screenshaker = load("res://Shaker.tscn").instantiate() as Shaker
	screenshaker.initialize(1, 0.025)
	get_viewport().get_camera_3d().add_child(screenshaker)
	await get_tree().create_timer(duration).timeout
	if screenshaker != null:
		screenshaker.end_shake()


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
			pass
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
