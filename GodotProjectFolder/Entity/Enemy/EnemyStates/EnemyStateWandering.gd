extends State


var enemy : PathfindingEntity

var move_duration = 100
var stand_duration = 200
var movement_counter = stand_duration

var target_seen = false
var process_duration = 0.5
var process_counter = process_duration

var move = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	target_seen = false
	enemy.move_speed = 4
	enemy.get_node("Red").visible = false
	enemy.get_node("Yellow").visible = false
	enemy.get_node("HealthBar").visible = false


func update(_delta):
	movement_counter -= 1
	if movement_counter < 0:
		move = !move
		if move:
			movement_counter = move_duration + randf_range(-50, 50)
			
			var rand_position = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
			enemy.agent.target_position = enemy.global_position + rand_position
			
		else:
			movement_counter = stand_duration + randf_range(-50, 50)
	
	if enemy.is_instance_visible(enemy.player):
		target_seen = true
	
	if target_seen:
		process_counter -= _delta
		if process_counter <= 0:
			process_counter = 0
			state_machine.transition_to("Alerted")
			return
	else:
		process_counter = process_duration
		
	
	enemy.update_facing(_delta)


func physics_update(_delta):
	if move:
		if enemy.agent.is_target_reachable():
			enemy.ai_move(_delta, enemy.agent.target_position, 3.0, false, false, false, 100.0)
	else:
		var hor_velocity = Vector2(enemy.velocity.x, enemy.velocity.z)
		var vert_velocity = enemy.velocity.y
		
		vert_velocity -= enemy.GRAVITY * _delta
		
		hor_velocity = hor_velocity.move_toward(Vector2.ZERO, enemy.move_decel * _delta)
		
		enemy.velocity = Vector3(hor_velocity.x, vert_velocity, hor_velocity.y)
		enemy.move_and_slide()
		


func exit():
	pass



