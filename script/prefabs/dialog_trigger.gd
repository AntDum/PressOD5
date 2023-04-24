extends Area2D

signal dialogic_signal(message)
export var timeline := ""

func _on_dialogue_trigger_body_entered(_body):
	trigger()

func trigger():
	get_node("/root/SceneManager/Dungeon/Player").block()
	var dialog = Dialogic.start(timeline)
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "transfere_signal")

func transfere_signal(message):
	get_node("/root/SceneManager/Dungeon/Player").force_idle()
	emit_signal("dialogic_signal", message)
	call_deferred("queue_free")
