extends State


var enemy : Entity

var lost_duration = 600
var lost_counter = lost_duration

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	enemy.move_speed = 9
	enemy.get_node("MeshInstance3D2").visible = true
	enemy.get_node("MeshInstance3D3").visible = false
	enemy.get_node("HealthBar").visible = true


func update(delta):
	if enemy.is_player_visible():
		lost_counter = lost_duration
	else:
		lost_counter -= 1
	
	if lost_counter <= 0:
		state_machine.transition_to("Wandering")


func physics_update(delta):
	enemy.ai_move(delta, enemy.player.global_position, 1.0, false, enemy.can_jump)
	enemy.update_facing(delta)


func exit():
	pass
