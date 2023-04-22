extends KinematicBody2D


export var speed := 200.0
var velocity := Vector2()

enum { STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_HURT }

var state = STATE_IDLE

func _physics_process(delta: float) -> void:
	match state:
		STATE_IDLE:
			pass
		STATE_WALKING:
			var input := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			velocity = input * speed
			velocity = move_and_slide(velocity)
		STATE_ATTACK:
			pass
		STATE_HURT:
			pass

