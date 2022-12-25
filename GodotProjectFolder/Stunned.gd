extends State


var enemy : Entity

var stun_duration = 600
var stun_counter = stun_duration

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	enemy = owner


func enter():
	# play stun animation
	stun_counter = stun_duration
	pass


func update(delta):
	stun_counter -= 1
	if stun_counter <= 0:
		state_machine.transition_to("Detected")


func physics_update(delta):
	enemy.velocity.y -= enemy.GRAVITY * delta
	enemy.move_and_slide()


func exit():
	pass
