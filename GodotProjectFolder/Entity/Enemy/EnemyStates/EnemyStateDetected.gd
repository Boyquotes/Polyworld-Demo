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
	
	# handle shooting
	if is_instance_valid(enemy.player):
		var rand = randi_range(0, 200)
		if rand == 0 && enemy.is_instance_visible(enemy.player):
			shoot()


func physics_update(_delta):
	
	if is_instance_valid(enemy.player):
		enemy.ai_move(_delta, enemy.player.global_position, 8.0, false, enemy.can_jump)
		# Look at player if stopped
		if enemy.velocity == Vector3.ZERO:
			enemy.face_toward(enemy.player.global_position)
	
	enemy.update_facing(_delta)


func exit():
	pass


func shoot():
	var ball = load("res://Attacks/Fireball.tscn").instantiate()
	ball.caster = enemy
	ball.direction = enemy.global_position.direction_to(enemy.player.global_position + enemy.player.velocity * enemy.global_position.distance_to(enemy.player.global_position) * 0.05)
	get_tree().root.add_child(ball)
	ball.global_position = enemy.global_position
