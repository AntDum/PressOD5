extends AnimationPlayer

func _ready():
	if OS.has_feature("editor"):
		end_bootsplash()
	else:
		play("STARTUP")

func end_bootsplash():
	get_tree().change_scene(ProjectSettings.get_setting("application/run/start_scene"))

