extends Node2D

export var enable = true

func flip():
	enable = not enable
	$body/shape.set_deferred("disabled", not enable)

func _on_lever_activated():
	flip()
