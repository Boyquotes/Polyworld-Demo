extends CharacterBody3D


var tb : Dialog
var interacting = false


func _process(delta):
	look_at(get_viewport().get_camera_3d().global_position)
	rotation.x = 0
	rotation.z = 0
	rotation.y += PI
	
	
	if interacting:
		get_viewport().get_camera_3d().get_parent().target_offset = (get_parent().get_node("Player").global_position - global_position) / 2
		get_viewport().get_camera_3d().get_parent().target_offset.y = 0

func _physics_process(delta):
	pass


func interact():
	
	if not interacting:
		interacting = true
		
		get_viewport().get_camera_3d().get_parent().target = self
		
		
		tb = load("res://Dialog.tscn").instantiate()
		tb.speaker = self
		tb.text = "Yo..._ You can hear me?
		So it's working!_ That's good to hear.
		Hope the rest of the game is working soon enough.__ [wavy]hehe...[/wavy]"
		get_parent().get_node("Interface").add_child(tb)
		await tb.finished
		await get_tree().create_timer(0.5).timeout
		
		tb = load("res://Dialog.tscn").instantiate()
		tb.speaker = self
		tb.text = "What's that?_ How did I get here?
		Huh..._ How DID I get here?
		These are some really tough questions.__ [wavy]Hmmm...[/wavy]
		I don't know what to tell ya,_ buddy.__ But I can tell you about cards."
		get_parent().get_node("Interface").add_child(tb)
		await tb.finished
		await get_tree().create_timer(0.5).timeout
		
		tb = load("res://Dialog.tscn").instantiate()
		tb.speaker = self
		tb.text = "Huh?_ What are cards?
		...
		Oh you're not kidding.__ You really don't know anything about this place.
		Here._ Take these."
		get_parent().get_node("Interface").add_child(tb)
		await tb.finished
		
		interacting = false
		get_viewport().get_camera_3d().get_parent().target = get_parent().get_node("Player")
		get_viewport().get_camera_3d().get_parent().target_offset = Vector3.ZERO
	
