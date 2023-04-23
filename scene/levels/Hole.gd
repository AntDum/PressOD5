extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_FitBox_area_entered(area):
	print("HOLE DESTROYED")
	queue_free()
	$CollisionShape2D.queue_free()
