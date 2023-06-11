extends StaticBody3D


var moving = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving:
		global_position.y += 0.1
	if global_position.y > 20:
		moving = false


func interact():
	var player = get_parent().get_node("Player") as Player
	player.interacting = true
	var tb = load("res://UI/Dialog.tscn").instantiate()
	tb.speaker = self
	tb.offset = -40
	
	if player.inventory.has_name("Dull Key"):
		player.inventory.remove_with_name("Dull Key")
		tb.text = "The door opens."
		get_parent().add_child(tb)
		await tb.finished
		moving = true
	
	else:
		tb.text = "Its position is locked."
		get_parent().add_child(tb)
		await tb.finished
	
	player.interacting = false
