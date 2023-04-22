extends KinematicBody2D


export var speed := 200.0
var velocity := Vector2()

enum { STATE_IDLE, STATE_WALKING, STATE_START_ATTACK, STATE_ATTACK, STATE_HURT, STATE_DIE, STATE_BLOCKED, STATE_NULL }

onready var anims = $Anim

var state = STATE_IDLE

var anim = ""
var new_anim = ""

var facing = "front"

func _physics_process(_delta: float) -> void:
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
				state = STATE_START_ATTACK
			_update_facing()
			new_anim = "idle_" + facing 
		STATE_WALKING:
			if Input.is_action_just_pressed("action"):
				state = STATE_START_ATTACK
			
			var input := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			velocity = input * speed
			velocity = move_and_slide(velocity)
			
			_update_facing()
			if velocity.length() > 5:
				new_anim = "walk_" + facing
			else:
				idle()
		
		STATE_START_ATTACK:
			_update_facing()
			new_anim = "attack_" + facing
			state = STATE_ATTACK
			
		STATE_ATTACK:
			var input := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			velocity = input * speed
			velocity = move_and_slide(velocity)

		STATE_HURT:
			pass
#			anim = "Hurt"
		STATE_DIE:
			new_anim = "Die"
			
		STATE_BLOCKED:
			pass
		STATE_NULL:
			pass
			

	if new_anim != anim:
		anim = new_anim
		anims.play(anim)

func idle(_n = null):
	state = STATE_IDLE
	velocity = Vector2.ZERO
	
func get_facing() -> String:
	return facing
	
func get_direction() -> Vector2:
	match facing:
		"front":
			return Vector2.DOWN
		"right":
			return Vector2.RIGHT
		"left":
			return Vector2.LEFT
		"back":
			return Vector2.UP
	return Vector2.ZERO
	
func _ready():
	anims.play("idle_front")

func _update_facing():
	if Input.is_action_pressed("move_left"):
		facing = "left"
	if Input.is_action_pressed("move_right"):
		facing = "right"
	if Input.is_action_pressed("move_up"):
		facing = "back"
	if Input.is_action_pressed("move_down"):
		facing = "front"
