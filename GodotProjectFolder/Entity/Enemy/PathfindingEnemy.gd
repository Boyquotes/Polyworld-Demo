class_name Enemy
extends PathfindingEntity


@export var can_jump = false

var player : Player
var rng = RandomNumberGenerator.new()


func _ready():
	super()
	player = get_parent().get_node("Player") as Player


func _on_entity_died():
	queue_free()


func _on_hurtbox_area_entered(hitbox : Hitbox):
	if hitbox.caster != self:
		if "contact" in hitbox.get_parent():
			hitbox.get_parent().contact()
		
		# TODO : replace vessel idea with simply discarding if the damage is 0. OR rename it to is_shell
		if hitbox.is_vessel:
			return
		take_damage(hitbox.damage)
		
		var impact_angle = hitbox.global_position.direction_to(global_position)
		if "direction" in hitbox.get_parent():
			impact_angle = hitbox.get_parent().direction
		velocity = Vector3(hitbox.push_force_horizontal * impact_angle.x, hitbox.push_force_vertical, hitbox.push_force_horizontal * impact_angle.z)
		
		$StateMachine.transition_to("Stunned")
		
