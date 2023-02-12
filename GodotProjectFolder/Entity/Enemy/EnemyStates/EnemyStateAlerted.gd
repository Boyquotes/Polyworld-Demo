extends State


var enemy : Entity


var surprise_duration = 0.4
var surprise_counter = surprise_duration


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	enemy.move_speed = 7
	enemy.get_node("Red").visible = false
	enemy.get_node("Yellow").visible = false
	enemy.get_node("HealthBar").visible = true
	
	enemy.velocity.y = enemy.jump_force / 2
	surprise_counter = surprise_duration


func update(_delta):
	surprise_counter -= _delta
	if surprise_counter <= 0:
		state_machine.transition_to("Detected")
	
	if is_instance_valid(enemy.player):
		enemy.face_toward(enemy.player.global_position)


func physics_update(_delta):
	enemy.ai_move(_delta, enemy.global_position, 1.0, false, enemy.can_jump)
	enemy.update_facing(_delta)


func exit():
	pass
