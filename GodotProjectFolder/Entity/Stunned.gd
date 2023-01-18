extends State


var entity : Entity

var stun_duration = 100
var stun_counter = stun_duration

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	entity = owner


func enter():
	# play stun animation
	stun_counter = stun_duration
	entity.get_node("HealthBar").visible = true
	
	entity.get_node("MeshInstance3D2").visible = false
	entity.get_node("MeshInstance3D3").visible = true
	entity.get_node("HealthBar").visible = true


func update(_delta):
	stun_counter -= 1
	if stun_counter <= 0:
		state_machine.transition_to("Detected")


func physics_update(_delta):
	entity.velocity.y -= entity.GRAVITY * _delta
	var hor_velocity = Vector2(entity.velocity.x, entity.velocity.z)
	if entity.is_on_floor():
		hor_velocity = hor_velocity.move_toward(Vector2.ZERO, 0.25)
	entity.velocity.x = hor_velocity.x
	entity.velocity.z = hor_velocity.y
	entity.move_and_slide()


func exit():
	pass
