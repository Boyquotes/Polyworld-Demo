class_name Inventory
extends Node


# CHANGE THIS TO USE AN ITEM DATATYPE INSTEAD OF STRING!!!
@export var iv : Array[String]


func _ready():
	pass



func _process(delta):
	pass



# Change to use item instead of string
func add(s : String):
	iv.append(s)

