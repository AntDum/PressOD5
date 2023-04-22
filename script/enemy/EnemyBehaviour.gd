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


enum State {
	HAPPY,			# Ignores the player, moves randomly around one point
	SURROUND,		# Gets close to the player and periodically CHARGE
	CHARGE,			# Charges towards the player, inflicting damage
}

export (State) var state = State.HAPPY

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
		State.SURROUND:
			charge_in = get_randf(charge_every_min, charge_every_max)
			current_target = pick_spot_around_player()
			time_since_target_change = 0
		State.CHARGE:
			pass

# Moves towards target, dt is the time step, leapfrog order 2 (kdk) integration
func move(target, dt):
	var diff = target - global_position
	# Stop moving if near target to avoid feedback loops and anihilation of the human race in a giant fireball
	if diff.length() < 10:
		velocity = Vector2.ZERO
		return
	var dir = diff.normalized()
	# Kick
	velocity += ACCEL * dt/2 * dir
	# Cap
	var vnorm = velocity.length()
	if vnorm > SPEED:
		velocity *= SPEED/vnorm
	# Drift
	move_and_slide(velocity)
	# Kick
	velocity += ACCEL * dt/2 * dir

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
	agressivity -= amount
	if agressivity < TRESHOLD:
		emit_signal("pacified")
		setState(State.HAPPY)

func take_physical_damage(amount):
	HP -= amount
	if HP <= 0:
		emit_signal("dead")

func _physics_process(delta):
	# Update time since last target change
	time_since_target_change += delta
	match state:
		State.SURROUND:
			# Update time until next charge
			charge_in -= delta
			# If time to charge and in range
			if charge_in < 0.0 and (global_position - player.global_position).length() < CHARGE_RANGE:
				charge_in = get_randf(charge_every_min, charge_every_max)
				print_debug("Attacking player")
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
					print_debug("Hit ", collision.collider.name)
					current_target = return_to_circle()
					setState(State.SURROUND)

func _on_PlayerEnteredArena(body):
	print("PLAYER ENTERED FIGHT ZONE")
	if(agressivity >= TRESHOLD):
		setState(State.SURROUND)

func _on_PlayerExitedArena(body):
	print("PLAYER EXITED FIGHT ZONE")
	setState(State.HAPPY)
