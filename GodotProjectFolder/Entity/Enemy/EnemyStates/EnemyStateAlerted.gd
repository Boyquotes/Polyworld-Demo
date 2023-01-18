extends State


var enemy : Entity

var lost_duration = 400
var lost_counter = lost_duration

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	enemy.move_speed = 7
	enemy.get_node("MeshInstance3D2").visible = false
	enemy.get_node("MeshInstance3D3").visible = true
	enemy.get_node("HealthBar").visible = true


func update(_delta):
	if enemy.is_instance_visible(enemy.player):
		lost_counter = lost_duration
	else:
		lost_counter -= 1
	
	if lost_counter <= 0:
		state_machine.transition_to("Wandering")


func physics_update(_delta):
	enemy.ai_move(_delta, enemy.player.global_position, 1.0, false, enemy.can_jump)
	enemy.update_facing(_delta)


func exit():
	pass