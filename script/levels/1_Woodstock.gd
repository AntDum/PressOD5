extends Node


signal change_scene(to)

func _ready():
	$anims.play("intro")

func _play_steal():
	$anims.play("steal")

func _launch_dialog_steal():
	var dialog = Dialogic.start("stealing")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "transfere_signal")

func transfere_signal(message):
	match message:
		"end":
			$Player.force_idle()
		"steal":
			_play_steal()

func _play_intro():
	print("START")
	$anims.play("start")

func _launch_intro():
	print("INTRO")
	var dialog = Dialogic.start("introduction")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "transfere_signal")
