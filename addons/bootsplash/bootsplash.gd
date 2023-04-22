tool
extends EditorPlugin

func _ready():
	if ProjectSettings.has_setting("application/run/start_scene") and ProjectSettings.get("application/run/start_scene"):
		get_editor_interface().open_scene_from_path(ProjectSettings.get("application/run/start_scene"))
		get_editor_interface().set_main_screen_editor("2D")
	
func _enter_tree():
	if not ProjectSettings.has_setting("application/run/start_scene"):
		ProjectSettings.set("application/run/start_scene", "")
		var property_info = {
		"name": "application/run/start_scene",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.tscn,*.scn,*.res"
		}
		ProjectSettings.set_order("application/run/start_scene", 1)
		ProjectSettings.add_property_info(property_info)
		var main_scene = ProjectSettings.get("application/run/main_scene")
		if main_scene:
			ProjectSettings.set("application/run/start_scene", main_scene)
		ProjectSettings.set("application/run/main_scene", "res://addons/bootsplash/BootSplash.tscn")
		ProjectSettings.set("application/boot_splash/image.editor", "res://addons/bootsplash/res/sprites/bootsplash.png")
		ProjectSettings.set("application/boot_splash/bg_color.editor", Color.white)
		ProjectSettings.set("application/boot_splash/bg_color", Color.black)
		ProjectSettings.set("application/boot_splash/use_filter", false)
		ProjectSettings.set("application/boot_splash/image", "res://addons/bootsplash/res/sprites/black.png")
		ProjectSettings.set_order("application/boot_splash/image.editor", 0)
		ProjectSettings.set_order("application/boot_splash/bg_color.editor", 0)
		ProjectSettings.save()


func _exit_tree():
	ProjectSettings.set("application/run/main_scene", ProjectSettings.get("application/run/start_scene"))
	ProjectSettings.set_setting("application/run/start_scene", null)
	ProjectSettings.set_setting("application/boot_splash/image.editor", null)
	ProjectSettings.set_setting("application/boot_splash/bg_color.editor", null)
	ProjectSettings.set_setting("application/boot_splash/image.32", null)
	ProjectSettings.set_setting("application/boot_splash/image.64", null)
	ProjectSettings.set_setting("application/boot_splash/bg_color.64", null)
	ProjectSettings.set_setting("application/boot_splash/bg_color.32", null)
	ProjectSettings.save()
