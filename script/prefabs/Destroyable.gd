extends StaticBody2D



func _on_HurtBox_area_entered(area):
	var tween = create_tween()
	tween.tween_callback($HurtBox, "queue_free")
	tween.tween_property($Sprite, "scale", Vector2.ZERO, 0.4)
	tween.tween_callback(self, "queue_free")
