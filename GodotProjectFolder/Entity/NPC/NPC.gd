extends Entity


var tb : Dialog
var interacting = false

@export var interaction_id = 0


func _process(_delta):	
		
		update_facing(_delta)
		
		if tb != null:
			get_viewport().get_camera_3d().get_parent().offset.y = tb.textbox.size.y / 50

func _physics_process(_delta):
	pass


func interact():
	
	if not interacting:
		interacting = true
		
		var camera_arm = get_viewport().get_camera_3d().get_parent()
		camera_arm.target = self
		#camera_arm.offset = Vector3.UP * 1
		
		
		var player = get_parent().get_node("Player")
		face_toward(player.global_position)
		
		
		if interaction_id == 0:
			tb = load("res://UI/Dialog.tscn").instantiate()
			tb.speaker = self
			tb.offset = -70
			tb.text = "Yo..._ You can hear me?
			So it's working!_ That's good to hear.
			Hope the rest of the game is working soon enough.__ [wavy]hehe...[/wavy]"
			get_parent().add_child(tb)
			await tb.finished
			await get_tree().create_timer(0.5).timeout
			
			tb = load("res://UI/Dialog.tscn").instantiate()
			tb.speaker = self
			tb.offset = -70
			tb.text = "What's that?_ How did I get here?
			Huh..._ How DID I get here?
			These are some really tough questions.__ [wavy]Hmmm...[/wavy]
			I don't know what to tell ya,_ buddy.__ But I can tell you about cards."
			get_parent().add_child(tb)
			await tb.finished
			await get_tree().create_timer(0.5).timeout
			
			tb = load("res://UI/Dialog.tscn").instantiate()
			tb.speaker = self
			tb.offset = -70
			tb.text = "Huh?_ What are cards?
			...
			Oh you're not kidding.__ You really don't know anything about this place.
			Here._ Take these."
			get_parent().add_child(tb)
			await tb.finished
			await get_tree().create_timer(0.5).timeout
			
		if interaction_id == 1:
			tb = load("res://UI/Dialog.tscn").instantiate()
			tb.speaker = self
			tb.offset = -70
			tb.text = "Whatsup bro.__ It's been a minute since the last time we talked.
			Whatchu been up to?
			You look a little lost.__ Which,_ I totally understand.
			Everything around here looks the same.__ Honestly,_ it's no wonder why so many of the others left.
			[wavy]sigh...[/wavy]
			At least you're here G.__ It's kinda sad just being up here alone most of the time."
			get_parent().add_child(tb)
			await tb.finished
		
		interacting = false
		camera_arm.target = get_parent().get_node("Player")
		camera_arm.offset = Vector3.ZERO
	
