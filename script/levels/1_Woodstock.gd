extends Node


signal change_scene(to)

func _ready():
	var aggressivity = PlayerInfo.aggressivity
	spawn_enemies(aggressivity)


func spawn_enemies(aggressivity):
	return null
