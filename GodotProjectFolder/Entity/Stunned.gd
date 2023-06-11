extends State


var entity : Entity

var stun_duration = 0.75
var stun_counter = stun_duration

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	entity = owner


func enter():
	# play stun animation
	stun_counter = stun_duration
	entity.get_node("HealthBar").visible = true
	
	entity.get_node("ModelContainer/Red").visible = false
	entity.get_node("ModelContainer/Yellow").visible = true
	entity.get_node("HealthBar").visible = true
	
	entity.model.shake(0.5, 0.96)
	
	# TODO : change this system
	entity.disable(entity)
	entity.disable(entity.player)
	await get_tree().create_timer(0.25).timeout
	entity.enable(entity)
	entity.enable(entity.player)
	


func update(delta):
	stun_counter -= delta
	if stun_counter <= 0:
		state_machine.transition_to("Detected")


func physics_update(delta):
	entity.velocity.y -= entity.GRAVITY * delta
	var hor_velocity = Vector2(entity.velocity.x, entity.velocity.z)
	if entity.is_on_floor():
		hor_velocity = hor_velocity.move_toward(Vector2.ZERO, 20 * delta)
	entity.velocity.x = hor_velocity.x
	entity.velocity.z = hor_velocity.y
	entity.move_and_slide()


func exit():
	pass
