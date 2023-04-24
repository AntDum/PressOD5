extends StaticBody2D


func _on_FitBox_area_entered(area):
	print("HOLE DESTROYED")
	queue_free()
	$CollisionShape2D.queue_free()
