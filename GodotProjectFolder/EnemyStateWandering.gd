extends State


var enemy : PathfindingEntity

var move_duration = 100
var stand_duration = 300
var movement_counter = stand_duration

var move = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	enemy.move_speed = 4
	enemy.get_node("MeshInstance3D2").visible = false
	enemy.get_node("MeshInstance3D3").visible = false


func update(delta):
	movement_counter -= 1
	if movement_counter < 0:
		move = !move
		if move:
			movement_counter = move_duration + randf_range(-50, 50)
			
			var rand_position = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
			enemy.agent.set_target_location(enemy.global_position + rand_position)
			
		else:
			movement_counter = stand_duration + randf_range(-50, 50)
	
	if enemy.is_player_visible():
			state_machine.transition_to("Detected")
	
	enemy.update_facing(delta)


func physics_update(delta):
	if move:
		if enemy.agent.is_target_reachable():
			enemy.ai_move(delta, enemy.agent.target_location, 3.0, false, false, false, 100.0)
			enemy.update_facing(delta)
	else:
		var hor_velocity = Vector2(enemy.velocity.x, enemy.velocity.z)
		var vert_velocity = enemy.velocity.y
		
		vert_velocity -= enemy.GRAVITY * delta
		
		hor_velocity = hor_velocity.move_toward(Vector2.ZERO, enemy.move_decel * delta)
		
		enemy.velocity = Vector3(hor_velocity.x, vert_velocity, hor_velocity.y)
		enemy.move_and_slide()
		


func exit():
	pass



