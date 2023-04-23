extends Node

var current_scene : Node

func change_scene(to: String) -> void:
	if current_scene:
		current_scene.free()
	current_scene = load(to).instance()
	add_child(current_scene)
	move_child(current_scene, 0)
	if current_scene.has_signal("change_scene"):
		current_scene.connect("change_scene", self, "change_scene", [], CONNECT_DEFERRED)
	

func _ready() -> void:
	call_deferred("change_scene", "res://scene/menu/Menu.tscn") 
