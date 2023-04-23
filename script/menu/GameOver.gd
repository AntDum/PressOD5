extends Control

signal change_scene(to)

func _ready():
	$anims.play("start")
#
func _on_Play_pressed():
	$anims.play("launch")

#
func _on_Quit_pressed():
	emit_signal("change_scene", "res://scene/menu/Menu.tscn")

func _play():
	emit_signal("change_scene", "last")
