extends KinematicBody2D

var direction
var limit
var start_pos
export var speed = 400

func _ready():
	$anims.play("idle")


func _on_HitBox_area_entered(area):
	var enemy = area.get_parent()
	if enemy.has_method("take_magical_damage"):
		enemy.take_magical_damage(PlayerInfo.hearth_damage)
		_destroy()


func _physics_process(delta):
	if (position.distance_to(start_pos) > limit):
		_destroy()
		return
		
	var velocity = move_and_slide(direction * speed)
	if (velocity.length() < 15):
		_destroy()

func _destroy():
	set_physics_process(false)
	$HitBox/CollisionShape2D.disabled = true
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property($Sprite, "scale", Vector2(0.15,0.15), 0.1)
	tween.tween_property($Sprite, "scale", Vector2(0,0), 0.1)
	tween.tween_callback(self, "queue_free")
