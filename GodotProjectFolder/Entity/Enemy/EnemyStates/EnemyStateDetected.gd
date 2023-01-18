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


func update(_delta):
	if enemy.is_instance_visible(enemy.player):
		lost_counter = lost_duration
	else:
		lost_counter -= 1
	
	if lost_counter <= 0:
		state_machine.transition_to("Wandering")


func physics_update(_delta):
	
	if is_instance_valid(enemy.player):
		enemy.ai_move(_delta, enemy.player.global_position, 10.0, false, enemy.can_jump)
		# Look at player if stopped
		if enemy.velocity == Vector3.ZERO:
			enemy.face_toward(enemy.player.global_position)
	
	enemy.update_facing(_delta)


func exit():
	pass
