extends State


var enemy : Entity

var stun_duration = 100
var stun_counter = stun_duration

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	# play stun animation
	stun_counter = stun_duration
	enemy.get_node("HealthBar").visible = true
	
	enemy.get_node("MeshInstance3D2").visible = false
	enemy.get_node("MeshInstance3D3").visible = true
	enemy.get_node("HealthBar").visible = true


func update(delta):
	stun_counter -= 1
	if stun_counter <= 0:
		state_machine.transition_to("Detected")


func physics_update(delta):
	enemy.velocity.y -= enemy.GRAVITY * delta
	var hor_velocity = Vector2(enemy.velocity.x, enemy.velocity.z)
	if enemy.is_on_floor():
		hor_velocity = hor_velocity.move_toward(Vector2.ZERO, 0.25)
	enemy.velocity.x = hor_velocity.x
	enemy.velocity.z = hor_velocity.y
	enemy.move_and_slide()


func exit():
	pass
