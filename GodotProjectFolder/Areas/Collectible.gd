class_name Collectible
extends Area3D


@export var item : Item


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer3D.stream = item.sound


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Sprite3D.texture != item.icon:
		$Sprite3D.texture = item.icon
		$Sprite3D.material_override.set_shader_parameter("texture_albedo", item.icon)


func _on_body_entered(body):
	if body is Player:
		var player_inventory = body.get_node("Inventory") as Inventory
		player_inventory.add(item)
		$AudioStreamPlayer3D.play()
		
		get_tree().paused = true
		await get_tree().create_timer(0.5).timeout
		get_tree().paused = false
		
		queue_free()
		
