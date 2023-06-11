class_name Inventory
extends Node


# CHANGE THIS TO USE AN ITEM DATATYPE INSTEAD OF STRING!!!
@export var iv : Array[Item]
@export var gold := 0


func _ready():
	pass


func _process(_delta):
	pass


# Change to use item instead of string
func add(item : Item):
	iv.append(item)
	for i in iv:
		print(i.item_name)


func remove_with_name(name : String):
	for i in iv.size():
		if iv[i].item_name == name:
			iv.remove_at(i)
			return true
	return false

func has_name(name : String):
	for item in iv:
		if item.item_name == name:
			return true
	return false
