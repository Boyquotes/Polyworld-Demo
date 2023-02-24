extends State


var enemy : Entity

var lost_duration = 5
var lost_counter = lost_duration

var attack_interval = 1
var attack_counter = attack_interval

var circling_phase = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	enemy.move_speed = 9
	enemy.get_node("Red").visible = true
	enemy.get_node("Yellow").visible = false
	enemy.get_node("HealthBar").visible = true
	
	attack_counter = attack_interval + randf_range(-0.5, 3)
	
	circling_phase = 0


func update(_delta):
	if enemy.is_instance_visible(enemy.player):
		lost_counter = lost_duration
		attack_counter -= _delta
		if attack_counter <= 0:
			attack_counter = attack_interval + randf_range(-0.5, 3)
			state_machine.transition_to("Attacking")
	else:
		attack_counter = attack_interval + randf_range(-0.5, 3)
		lost_counter -= _delta
	
	if lost_counter <= 0:
		state_machine.transition_to("Wandering")


func physics_update(_delta):
	
	if is_instance_valid(enemy.player):
		
		if enemy.global_position.distance_to(enemy.player.global_position) < 12.0:
			enemy.move_speed = 5
			enemy.face_toward(enemy.player.global_position)
			circling_phase += _delta * 0.2
			var forward_dir = enemy.player.global_position.direction_to(enemy.global_position)
			forward_dir.y = 0
			forward_dir = forward_dir.normalized()
			var circling_offset = forward_dir.rotated(Vector3.UP, circling_phase) * 10
			var target_location = Vector3(enemy.player.global_position.x, enemy.global_position.y, enemy.player.global_position.z)
			enemy.ai_move(_delta, target_location + circling_offset, 0.0, false, false)
		else:
			enemy.move_speed = 7
			enemy.face_toward(enemy.player.global_position)
			enemy.ai_move(_delta, enemy.player.global_position, 12.0, false, enemy.can_jump)
			circling_phase = 0
			
		# Look at player if stopped
		if enemy.velocity == Vector3.ZERO:
			enemy.face_toward(enemy.player.global_position)
		
	
	enemy.update_facing(_delta)


func exit():
	pass
