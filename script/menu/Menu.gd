extends Control

signal change_scene(to)

func _ready():
	$anims.play("start")

func _on_Play_pressed():
	#var dialog = Dialogic.start("metal_interaction_1")
	#var dialog = Dialogic.start("introduction")
	#add_child(dialog)
	emit_signal("change_scene", "res://scene/levels/1_Woodstock.tscn")


func _on_Quit_pressed():
	get_tree().quit()
