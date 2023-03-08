class_name StateMachine
extends Node

# Change this to State type once feature is implemented
@export var current_state : Node


# Called when the node enters the scene tree for the first time.
func _ready():
	# WTF is this bruh vvvvvvvv
	await get_parent().ready
	current_state.enter()


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	current_state.update(_delta)


func _physics_process(_delta):
	current_state.physics_update(_delta)


func transition_to(target_state_name : String):
	current_state.exit()
	current_state = get_node(target_state_name)
	current_state.enter()
