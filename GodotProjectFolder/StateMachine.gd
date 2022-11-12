class_name StateMachine
extends Node

# Change this to State type once feature is implemented
@export var current_state : Node


# Called when the node enters the scene tree for the first time.
func _ready():
	current_state.enter()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_state.update(delta)


func _physics_process(delta):
	current_state.physics_update(delta)


func transition_to(target_state_name : String):
	current_state.exit()
	current_state = get_node(target_state_name)
	current_state.enter()
