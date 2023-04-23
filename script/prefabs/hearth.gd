extends Area2D

func _ready():
	$anims.play("idle")



func _on_Hearth_body_entered(body):
	set_physics_process(false)



func _on_HitBox_area_entered(area):
	var enemy = area.get_parent()
	if enemy.has_method()
