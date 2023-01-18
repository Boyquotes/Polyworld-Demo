class_name Partner
extends PathfindingEntity


@export var leader : Entity
var rng = RandomNumberGenerator.new()

var is_being_called = false


func _ready():
	super()


func _process(_delta):
	#attacking(player)
	pass


func _physics_process(_delta):
	
	if is_being_called:
		pass
	else:
		if is_instance_valid(leader):
			ai_move(_delta, leader.global_position, 3.0, true)
			if global_position.distance_to(leader.global_position) > 15:
				global_position = leader.global_position + Vector3.UP * 5
		else:
			# If the leader is invalid, stop moving (but still apply gravity)
			ai_move(_delta, global_position)
			
	update_facing(_delta)
	
	

