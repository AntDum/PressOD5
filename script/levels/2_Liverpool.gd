extends Node

signal change_scene(to)

var player

func _ready():
	$Arena.player = $Player
	$Arena2.player = $Player
	player = $Player
	
func _on_Arena2_arenaCleared():
	var dialog = Dialogic.start("unlock_join")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "transfere_signal")
	
func transfere_signal(message):
	PlayerInfo.spell_1_unlock = true
	next_level()
	
func next_level():
	emit_signal("change_scene", "res://scene/levels/3_Hellfest.tscn")
