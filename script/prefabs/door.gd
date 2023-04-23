extends Node2D

export var enable = true

func flip():
	enable = not enable
	$body/shape.set_deferred("disabled", not enable)

func open():
	enable = false
	$body/shape.set_deferred("disabled", true)
	$Sprite.set_deferred("visible",false)
	
	
func close():
	enable = true
	$body/shape.set_deferred("disabled", false)
	$Sprite.set_deferred("visible",true)

func _on_lever_activated():
	flip()


func _on_Arena_arenaCleared():
	flip()
	
func _on_goodLever_activated():
	print("Opening door")
	open()
	
func _on_badLever_activated():
	print("Closing door")
	close()


func _on_wrongLever_activated():
	pass # Replace with function body.


func _on_leverRed2_activated():
	pass # Replace with function body.
