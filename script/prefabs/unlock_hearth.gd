extends Node2D

func _on_dialogue_trigger_dialogic_signal(message):
	PlayerInfo.spell_2_unlock = true
