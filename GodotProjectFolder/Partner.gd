class_name Partner
extends PathfindingEntity


@export var leader : Entity
var rng = RandomNumberGenerator.new()

var is_being_called = false


func _ready():
	super()


func _process(delta):
	#attacking(player)
	pass


func _physics_process(delta):
	
	if is_being_called:
		pass
	else:
		ai_move(delta, leader.global_position, 3.0, true)
		if global_position.distance_to(leader.global_position) > 15:
			global_position = leader.global_position + Vector3.UP * 5
			
	update_facing(delta)
	
	

