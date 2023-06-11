class_name Partner
extends PathfindingEntity


@export var leader : Entity
var rng = RandomNumberGenerator.new()

var is_being_summoned := false
var summon_start_pos : Vector3
var summon_destination : Vector3
var summon_interpolation_interval := 0.0
var summon_interpolation := 0.0:
	set(val):
		summon_interpolation = clamp(val, 0, 1)
		reached_summon_destination = summon_interpolation == 1
var reached_summon_destination := false

func _ready():
	# TODO : is there a better way than using super() ?
	super()


func _process(_delta):
	
	# TODO : change this method ? I think pathfinding entities should use state machines honestly
	if is_on_floor():
		if velocity.length() < 1:
			$Sprite3D2/AnimationPlayer.play("idle")
			$DustTrail.emitting = false
		else:
			if $Sprite3D2/AnimationPlayer.current_animation != "run":
				$Sprite3D2/AnimationPlayer.play("run")
			$DustTrail.emitting = true
			$Sprite3D2/AnimationPlayer.speed_scale = clamp(velocity.length() / move_speed, 0, 1.2)
	else:
		if $Sprite3D2/AnimationPlayer.assigned_animation != "jump":
			$Sprite3D2/AnimationPlayer.play("jump")
		$DustTrail.emitting = false


func _physics_process(_delta):
	
	if is_being_summoned:
		summon_interpolation += summon_interpolation_interval * _delta
		global_position = summon_start_pos.lerp(summon_destination, summon_interpolation)
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
	var player = leader
	face_toward(player.global_position)
	player.interacting = true
	var tb = load("res://UI/Dialog.tscn").instantiate()
	tb.speaker = self
	tb.offset = -40
	tb.voice = load("res://Sounds/voice1.wav")
	tb.voice_pitch = 2
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
	

# THIS IS FLAWED, BECAUSE THE DESTINATION VEC IS LIKELY TO CHANGE WHILE BEING summoned
func summon(dur : float, dest : Vector3 = summon_destination):
	summon_interpolation = 0
	summon_start_pos = global_position
	summon_destination = dest
	summon_interpolation_interval = 1 / dur
	is_being_summoned = true
	
