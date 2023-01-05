extends State


var player : Player

var attack_length = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	player = owner


func enter():
	
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	
	attack_length = 0
	
	await get_tree().create_timer(0.25).timeout
	
	var burst = load("res://Attacks/BurningFist.tscn").instantiate()
	burst.caster = player
	get_tree().root.add_child(burst)
	player.velocity = player.aim_direction * 60
	
	await get_tree().create_timer(0.2).timeout
	state_machine.transition_to("Idle")


func update(delta):
	pass


func physics_update(delta):
	
	player.anim.play("thrust")
	
	player.facing_dir_target = Vector2(player.aim_direction.x, player.aim_direction.z)
	
	player.move_and_slide()
	
	var hor_velocity = Vector2(player.velocity.x, player.velocity.z)
	hor_velocity *= 0.9
	player.velocity.x = hor_velocity.x
	player.velocity.z = hor_velocity.y
	


func exit():
	pass
