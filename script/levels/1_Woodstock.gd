extends Node


signal change_scene(to)

func _ready():
	var dialog = Dialogic.start("introduction")
	add_child(dialog)
	$Player.state = $Player.STATE_NULL
	$Arenas/Node2D.player = $Player
	
	dialog.connect("dialogic_signal", $Player, "idle")

