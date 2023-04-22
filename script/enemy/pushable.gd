extends KinematicBody2D

var direction
var start_pos
export var speed = 150
export var limit = 500

func _ready():
	set_physics_process(false)

func _on_HurtBox_area_entered(area):
	var player = area.get_parent()
	if player.has_method("get_direction"):
		direction = player.get_direction()
		set_physics_process(true)
		start_pos = position
		
		

func _physics_process(delta):
	if (position.distance_to(start_pos) > limit):
		set_physics_process(false)
		return
	var velocity = move_and_slide(direction * speed)
	if (velocity.length() < 5):
		set_physics_process(false)
