extends Node2D

signal activated

func _on_HurtBox_area_entered(area):
	emit_signal("activated")
