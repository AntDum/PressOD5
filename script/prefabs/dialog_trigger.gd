extends Area2D

signal dialogic_signal(message)
export var timeline := ""
onready var player = $"%Player"

func _on_Area2D_area_entered(_area):
	trigger()

func _on_dialogue_trigger_body_entered(_body):
	trigger()

func trigger():
	player.state = player.STATE_NULL
	var dialog = Dialogic.start(timeline)
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "transfere_signal")

func transfere_signal(message):
	print("HELLO")
	player.idle()
	emit_signal("dialogic_signal", message)
	call_deferred("queue_free")
