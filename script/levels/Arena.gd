extends Node2D


export (PackedScene) var enemy


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn(amount,agressivity):
	for i in range(amount):
		
