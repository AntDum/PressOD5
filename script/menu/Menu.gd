extends Control

signal change_scene(to)


func _on_Play_pressed():
	emit_signal("change_scene", "res://scene/levels/1_Woodstock.tscn")
