extends State


var player : Player

var stun_duration = 0.5


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.velocity.y = 5
	


func update(_delta):
	stun_duration -= _delta
	if stun_duration <= 0:
		if player.is_on_floor():
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("InAir")


func physics_update(_delta):
	
	player.anim.play("hurt")
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * _delta
	
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	hor_velocity = hor_velocity.move_toward(Vector2.ZERO, 20 * _delta)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	player.move_and_slide()
	


func exit():
	pass
