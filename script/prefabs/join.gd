extends Node2D


func _on_Timer_timeout():
	_destroy()
	
func _on_HitBox_area_entered(area):
	var enemy = area.get_parent()
	if enemy.has_method("take_magical_damage"):
		enemy.take_magical_damage(PlayerInfo.join_damage)
		_destroy()


func _destroy():
	set_physics_process(false)
	$HitBox/CollisionShape2D.disabled = true
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property($sprite, "scale", Vector2(0.17,0.17), 0.1)
	tween.tween_property($sprite, "scale", Vector2(0,0), 0.1)
	tween.tween_callback(self, "queue_free")
