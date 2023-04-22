extends Area2D

signal dialogic_signal(message)
export var timeline := ""

func _on_Area2D_area_entered(area):
	$"%Player".state = $"%Player".STATE_NULL
	var dialog = Dialogic.start(timeline)
	add_child(dialog)
	connect("dialogic_signal", dialog, "transfere_signal")

func transfere_signal(message):
	emit_signal("dialogic_signal", message)
