extends State


var player : Player

var stun_duration = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	player.vert_velocity = 10
	
	player.partner.is_being_summoned = false


func update(_delta):
	stun_duration -= _delta
	if stun_duration <= 0:
		if player.is_on_floor():
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("InAir")


func physics_update(_delta):
	
	#player.anim.play("hurt")
	
	# Add the gravity
	player.vert_velocity -= player.GRAVITY * _delta
	
	player.hor_velocity = player.hor_velocity.move_toward(Vector2.ZERO, 20 * _delta)
	
	player.apply_velocities()
	


func exit():
	player.damage_boost()
