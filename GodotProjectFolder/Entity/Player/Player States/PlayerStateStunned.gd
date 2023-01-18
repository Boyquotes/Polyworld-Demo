extends State


var player : Player

var stun_duration = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.velocity.y = 5
	print("hurt")
	


func update(_delta):
	pass


func physics_update(_delta):
	
	player.anim.play("hurt")
	
	# Add the gravity
	player.velocity.y -= player.GRAVITY * _delta
	
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	hor_velocity = hor_velocity.move_toward(Vector2.ZERO, player.move_decel * _delta)
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	
	player.move_and_slide()
	
	stun_duration -= _delta
	
	if stun_duration <= 0:
		if player.is_on_floor():
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("InAir")
	


func exit():
	print("exiting")