extends State


var enemy : Entity

var anticipation_time = 0.5
var anticipation_counter = anticipation_time

var attacked = false

var recovery_time = 0.75
var recovery_counter = recovery_time


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	enemy.get_node("ModelContainer/Red").visible = true
	enemy.get_node("ModelContainer/Yellow").visible = false
	enemy.get_node("HealthBar").visible = true
	enemy.get_node("AttackingIcon").visible = true
	
	attacked = false
	anticipation_counter = anticipation_time
	recovery_counter = recovery_time


func update(_delta):
	if !attacked:
		enemy.get_node("AttackingIcon").visible = true
		enemy.get_node("ModelContainer/Gray").visible = false
		anticipation_counter -= _delta
		if anticipation_counter <= 0:
			anticipation_counter = anticipation_time
			shoot()
			attacked = true
	else:
		enemy.get_node("AttackingIcon").visible = false
		enemy.get_node("ModelContainer/Gray").visible = true
		recovery_counter -= _delta
		if recovery_counter <= 0:
			recovery_counter = recovery_time
			anticipation_counter = anticipation_time
			state_machine.transition_to("Detected")


func physics_update(_delta):
	
	if is_instance_valid(enemy.player):
		enemy.ai_move(_delta, enemy.global_position, 12.0, false, false)
		enemy.face_toward(enemy.player.global_position)
	
	enemy.update_facing(_delta)


func exit():
	enemy.get_node("AttackingIcon").visible = false
	enemy.get_node("ModelContainer/Gray").visible = false


func shoot():
	var ball = load("res://Attacks/Fireball.tscn").instantiate()
	ball.caster = enemy
	ball.direction = enemy.global_position.direction_to(enemy.player.global_position + enemy.player.velocity * enemy.global_position.distance_to(enemy.player.global_position) * 0.05)
	get_tree().root.add_child(ball)
	ball.global_position = enemy.global_position
