class_name Partner
extends PathfindingEntity


@export var leader : Entity
var rng = RandomNumberGenerator.new()

var is_being_called := false
var calling_start_pos : Vector3
var calling_end_pos : Vector3
var calling_interpolation_interval := 0.0
var calling_interpolation := 0.0:
	set(val):
		calling_interpolation = clamp(val, 0, 1)
		call_arrived = calling_interpolation == 1
var call_arrived := false

func _ready():
	# TODO : is there a better way than using super() ?
	super()


func _process(_delta):
	
	# TODO : change this method ? I think pathfinding entities should use state machines honestly
	if is_on_floor():
		if running:
			$Sprite3D2/AnimationPlayer.play("run")
			$DustTrail.emitting = true
		else:
			$Sprite3D2/AnimationPlayer.play("idle")
			$DustTrail.emitting = false
	else:
		$Sprite3D2/AnimationPlayer.play("jump")
		$DustTrail.emitting = false


func _physics_process(_delta):
	
	if is_being_called:
		calling_interpolation += calling_interpolation_interval * _delta
		global_position = calling_start_pos.lerp(calling_end_pos, calling_interpolation)
	else:
		if is_instance_valid(leader):
			ai_move(_delta, leader.global_position, 4.0, true)
			
			# Respawn partner above player if it is too far away
			if global_position.distance_to(leader.global_position) > 15:
				global_position = leader.global_position + Vector3.UP * 5
		else:
			# If the leader is invalid, stop moving (but still apply gravity)
			ai_move(_delta, global_position)
			
	update_facing(_delta)
	

func interact():
	var player = get_parent().get_node("Player")
	face_toward(player.global_position)
	player.interacting = true
	var tb = load("res://UI/Dialog.tscn").instantiate()
	tb.speaker = self
	tb.offset = -40
	tb.text = "[wavy]hello...[/wavy]
	Sorry,_ is there a problem?"
	get_parent().add_child(tb)
	await tb.finished
	player.interacting = false


func contact():
	var explosion = load("res://Attacks/Explosion.tscn").instantiate()
	explosion.global_position = global_position
	explosion.caster = leader
	get_tree().root.add_child(explosion)
	

# THIS IS FLAWED, BECAUSE THE DESTINATION VEC IS LIKELY TO CHANGE WHILE BEING CALLED
func call_toward(dest : Vector3, dur : float):
	calling_interpolation = 0
	calling_start_pos = global_position
	calling_end_pos = dest
	calling_interpolation_interval = 1 / dur
	is_being_called = true
	
