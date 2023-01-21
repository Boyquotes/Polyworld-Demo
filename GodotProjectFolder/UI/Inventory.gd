class_name Inventory
extends Node


# CHANGE THIS TO USE AN ITEM DATATYPE INSTEAD OF STRING!!!
@export var iv : Array[String]
@export var gold := 0


func _ready():
	pass



func _process(_delta):
	pass



# Change to use item instead of string
func add(s : String):
	iv.append(s)

