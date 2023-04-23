# Plan:
# 	When happy, move around a fixed point
# 	When sourrounding, move around the player, waiting to attack
# 	When charging, dash towards the player and come back to position

extends KinematicBody2D

export (float) var SPEED = 100
export (float) var ACCEL = 500
export (float) var CHARGE_RANGE = 210
const TRESHOLD = 1

signal pacified
signal dead

var hitSound = preload("res://assets/sounds/hitHurt.wav")

enum State {
	HAPPY,			# Ignores the player, moves randomly around one point
	SURROUND,		# Gets close to the player and periodically CHARGE
	CHARGE,			# Charges towards the player, inflicting damage
	KICK,
}

export (State) var state = State.HAPPY

onready var anims = $anims
var anim = ""
var new_anim = ""

var randGen = RandomNumberGenerator.new()

func get_randf(from, to):
	randGen.randomize()
	return from + (to - from)*randGen.randf()

var agressivity = 0.0
var HP = 3
var velocity = Vector2.ZERO

# Point around which to walk when in happy state
var happy_center = Vector2.ZERO
var happy_angle = 0.0

# Controls how often the enemy charges when in SURROUND state
var charge_every_max = 10.0
var charge_every_min = 3.0
var charge_in = 0.0


# After how many time to pick a new target
export (float) var change_target_every = 5.0
# Current value of the timer
var time_since_target_change = change_target_every + 0.1

var current_target

var player

func back_to_idle():
	anims.play("idle_front")
	current_target = return_to_circle()
	anim = "idle_front"
	new_anim = "idle_front"
	charge_in = get_randf(charge_every_min, charge_every_max)
	setState(State.SURROUND)

# Determine state based on agressivity
func setAgressivity(value):
	agressivity = value
	if value >= TRESHOLD:
		setState(State.SURROUND)
	else:
		setState(State.HAPPY)

# Set state and handle everything
func setState(newState):
	state = newState
	match state:
		State.HAPPY:
			happy_center = global_position
			current_target = pick_happy_spot(get_randf(0.0, 1.0))
			time_since_target_change = 0
			show_angryness(0)
		State.SURROUND:
			charge_in = get_randf(charge_every_min, charge_every_max)
			current_target = pick_spot_around_player()
			time_since_target_change = 0
			show_angryness(4)
		State.CHARGE:
			pass

func show_angryness(angry_num):
	var tween = create_tween()
	tween.tween_property($angryness, "visible", true, 0)
	tween.tween_property($angryness, "frame", angry_num, 1)
	tween.tween_interval(5)
	tween.tween_property($angryness, "visible", false, 0)
	
	

# Moves towards target, dt is the time step, leapfrog order 2 (kdk) integration
func move(target, dt):
	var diff = target - global_position
	# Stop moving if near target to avoid feedback loops and anihilation of the human race in a giant fireball
	if diff.length() < 10:
		velocity = Vector2.ZERO
		new_anim = "idle_front"
		return
	var dir = diff.normalized()
	# Kick
	velocity += ACCEL * dt/2 * dir
	
	# Anim
	var walk_angle = atan2(velocity.y, velocity.x) + PI
	if walk_angle < PI/4 or walk_angle > 7*PI/4:
		new_anim = "walk_left"
	elif walk_angle < 3*PI/4:
		new_anim = "walk_back"
	elif walk_angle < 5*PI/4:
		new_anim = "walk_right"
	else:
		new_anim = "walk_front"
	
	# Cap
	var vnorm = velocity.length()
	if vnorm > SPEED:
		velocity *= SPEED/vnorm
	# Drift
	move_and_slide(velocity)
	# Kick
	velocity += ACCEL * dt/2 * dir
	if new_anim != anim:
		anim = new_anim
		anims.play(anim)

func pick_spot_around_player():
	var center = player.global_position
	var distance = 200
	var angle_with_player = atan2(global_position.y - center.y, global_position.x - center.x)

	var angle = get_randf(angle_with_player-PI/3, angle_with_player+PI/3)

	var x = center.x + cos(angle) * distance
	var y = center.y + sin(angle) * distance

	return Vector2(x, y)

func return_to_circle():
	var center = player.global_position
	var distance = 200
	var angle_with_player = atan2(global_position.y - center.y, global_position.x - center.x)

	var angle = angle_with_player

	var x = center.x + cos(angle) * distance
	var y = center.y + sin(angle) * distance

	return Vector2(x, y)

func pick_happy_spot(angle):
	var distance = 40

	var x = happy_center.x + cos(angle) * distance
	var y = happy_center.y + sin(angle) * distance

	return Vector2(x, y)

# Called when the node enters the scene tree for the first time.
func _ready():
	setState(State.HAPPY) # Replace with function body.

func take_magical_damage(amount):
	setAgressivity(agressivity - amount)
	if agressivity < 0:
		agressivity = 0
	if agressivity < TRESHOLD:
		emit_signal("pacified")
		setState(State.HAPPY)

func take_physical_damage(amount):
	HP -= amount
	$AudioStreamPlayer.set_stream(hitSound)
	$AudioStreamPlayer.play()
		
func set_player(plr):
	player = plr

func _physics_process(delta):
	# Update time since last target change
	time_since_target_change += delta
	match state:
		State.SURROUND:
			# Update time until next charge
			charge_in -= delta
			# If time to charge and in range
			if charge_in < 0.0 and (global_position - player.global_position).length() < CHARGE_RANGE:
				setState(State.CHARGE)
			# If time to change target
			if time_since_target_change > change_target_every:
				current_target = pick_spot_around_player()
				time_since_target_change = 0
			move(current_target, delta)
		State.HAPPY:
			if time_since_target_change > change_target_every:
				# Stop before changing target to avoid orbits
				velocity = Vector2.ZERO
				happy_angle = get_randf(0.0, 2.0*PI)
				# Only change relative position when it is time to do so
				time_since_target_change = 0
			# But update position as player moves for every physics tick
			current_target = pick_happy_spot(happy_angle)
			move(current_target, delta)
		State.CHARGE:
			current_target = player.global_position
			move(current_target, delta)
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision.collider.name == "Player":
					state = State.KICK
					# Anim
					var walk_angle = atan2(velocity.y, velocity.x) + PI
					if walk_angle < PI/4 or walk_angle > 7*PI/4:
						anims.play("attack_left")
					elif walk_angle < 3*PI/4:
						anims.play("attack_back")
					elif walk_angle < 5*PI/4:
						anims.play("attack_right")
					else:
						anims.play("attack_front")
	if new_anim != anim:
		anim = new_anim
		anims.play(anim)

func _on_PlayerEnteredArena(body):
	if(agressivity >= TRESHOLD):
		setState(State.SURROUND)

func _on_PlayerExitedArena(body):
	setState(State.HAPPY)

func _on_AudioStreamPlayer_finished():
	if HP <= 0:
		queue_free()
		emit_signal("dead")
