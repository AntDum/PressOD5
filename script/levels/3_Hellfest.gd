extends Node

func _ready():
	$Arena.player = $Player


func _on_Arena_arenaCleared():
	$Player.block()
	var dialog = Dialogic.start("ending")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "transfere_signal")
	
func transfere_signal(message):
	$Player.force_idle()
	PlayerInfo.spell_3_unlock = true
	PlayerInfo.aggressivity = -10
	$Arena.remaining_mobs = 15
	$Arena.aggressivity = -10
	$Arena.spawn()
