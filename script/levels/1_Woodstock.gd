extends Node


signal change_scene(to)

func _ready():
	var dialog = Dialogic.start("introduction")
	add_child(dialog)
	
	$Arenas/Node2D.player = $Player


