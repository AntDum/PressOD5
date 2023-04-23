extends Node2D

signal activated

var enable = true

#var on_sprite = preload("res://assets/sprites/objects/IMG_0400.PNG")
#var off_sprite = preload("res://assets/sprites/objects/IMG_0399.PNG")

func _on_HurtBox_area_entered(area):
	enable = not enable
	_update_sprite()
	emit_signal("activated")
	
func _update_sprite():
	if enable:
		$Sprite.scale.x = 0.01
		$Sprite.position.x = 5
	else:
		$Sprite.scale.x = 0.02
		$Sprite.position.x = 0
