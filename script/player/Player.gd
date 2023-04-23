extends KinematicBody2D


export var speed := 200.0
export var spell_trap_dist := 200
export var spell_coeur_dist := 275

var velocity := Vector2()

enum  { STATE_IDLE, STATE_WALKING, STATE_START_ATTACK, STATE_ATTACK, STATE_HURT, STATE_DIE, STATE_BLOCKED, STATE_NULL, STATE_CAST_1, STATE_CAST_2, STATE_CAST_3 }

onready var anims = $Anim
onready var placeHolderTrap = $placeHolderTrap
onready var rayCastSpell = $rayCastSpell

var hearthScene = preload("res://scene/prefabs/hearth.tscn")
var joinScene = preload("res://scene/prefabs/join.tscn")

var hit_sound = preload("res://assets/sounds/player_hit.wav")
var shoot_sound = preload("res://assets/sounds/shoot_heart.wav")
var joint_sound = preload("res://assets/sounds/place_joint.wav")
var music_sound = preload("res://assets/sounds/music.mp3")

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
			_get_action()
			_update_facing()
			new_anim = "idle_" + facing 
			
		STATE_WALKING:
			_get_action()
			
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
			new_anim = "hurt"

		STATE_DIE:
			new_anim = "Die"
			
		STATE_BLOCKED:
			pass
		STATE_NULL:
			pass
		STATE_CAST_1:
			var join = joinScene.instance()
			join.position = placeHolderTrap.position + position
			get_parent().add_child(join)
			new_anim = "shoot_love_" + facing
			$AudioStreamPlayer.set_stream(joint_sound)
			$AudioStreamPlayer.play()
			state = STATE_NULL
		STATE_CAST_2:
			var hearth = hearthScene.instance()
			hearth.start_pos = position
			hearth.position = position
			hearth.limit = position.distance_to(rayCastSpell.cast_to + position)
			hearth.direction = position.direction_to(rayCastSpell.cast_to + position)
			get_parent().add_child(hearth)
			$AudioStreamPlayer.set_stream(shoot_sound)
			$AudioStreamPlayer.play()
			new_anim = "shoot_love_" + facing
			state = STATE_NULL
		STATE_CAST_3:
			new_anim = "shoot_love_" + facing
			$AudioStreamPlayer.set_stream(music_sound)
			$AudioStreamPlayer.play()
			state = STATE_NULL
			

	if new_anim != anim:
		anim = new_anim
		anims.play(anim)

func idle(_n = null):
	if state != STATE_BLOCKED:
		state = STATE_IDLE
		velocity = Vector2.ZERO

func force_idle(_n = null):
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
	$Camera2D/Fade.black()
	yield(get_tree(), "idle_frame")
	if (state != STATE_BLOCKED):
		$Camera2D/Fade.fade_out()
	
func _get_action():
	if Input.is_action_just_pressed("action"):
		state = STATE_START_ATTACK
	if Input.is_action_just_pressed("sort_1") and PlayerInfo.spell_1_unlock:
		state = STATE_CAST_1
	if Input.is_action_just_pressed("sort_2") and PlayerInfo.spell_2_unlock:
		state = STATE_CAST_2
	if Input.is_action_just_pressed("sort_3") and PlayerInfo.spell_3_unlock:
		state = STATE_CAST_3


func _update_facing():
	if Input.is_action_pressed("move_left"):
		facing = "left"
	if Input.is_action_pressed("move_right"):
		facing = "right"
	if Input.is_action_pressed("move_up"):
		facing = "back"
	if Input.is_action_pressed("move_down"):
		facing = "front"
	
	var direction = velocity.normalized()
	
	if (direction.length() < 0.1):
		direction = get_direction()
		
	placeHolderTrap.position = direction * spell_trap_dist
	rayCastSpell.cast_to = direction * spell_coeur_dist
	


func _on_HitBox_area_entered(area):
	var enemy = area.get_parent()
	if enemy.has_method("take_physical_damage"):
		enemy.take_physical_damage(1)
		
func block():
	state = STATE_BLOCKED


func _on_HurtBox_area_entered(area):
	$AudioStreamPlayer_damage.set_stream(hit_sound)
	$AudioStreamPlayer_damage.play()
	PlayerInfo.life -= 1
	


func _on_AudioStreamPlayer_damage_finished():
	if PlayerInfo.life <= 0:
		get_parent().emit_signal("change_scene", "res://scene/menu/GameOver.tscn")
