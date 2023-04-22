extends KinematicBody2D


export var speed := 200.0
var velocity := Vector2()

enum { STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_HURT, STATE_DIE, STATE_BLOCKED }

onready var anims = $Anim

var state = STATE_IDLE

var anim = ""
var new_anim = ""

func _physics_process(delta: float) -> void:
	match state:
		STATE_IDLE:
			if (
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up")
				):
					state = STATE_WALKING
			if Input.is_action_just_pressed("action"):
				state = STATE_ATTACK
			new_anim = "Idle"
		STATE_WALKING:
			if Input.is_action_just_pressed("action"):
				state = STATE_ATTACK
			
			var input := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			velocity = input * speed
			velocity = move_and_slide(velocity)
			
			if velocity.length() > 5:
				new_anim = "walk"
			else:
				idle()
			
		STATE_ATTACK:
			new_anim = "Attack"
		STATE_HURT:
			pass
#			anim = "Hurt"
		STATE_DIE:
			new_anim = "Die"
		STATE_BLOCKED:
			pass

	if new_anim != anim:
		anim = new_anim
		anims.play(anim)

func idle():
	state = STATE_IDLE
	velocity = Vector2.ZERO
