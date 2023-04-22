# Plan:
# 	When happy, move around a fixed point
# 	When sourrounding, move around the player, waiting to attack
# 	When charging, dash towards the player and come back to position

extends KinematicBody2D

export (float) var SPEED = 50
export (float) var ACCEL = 50
export (float) var CHARGE_RANGE = 70
const TRESHOLD = 1

signal pacified


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
	global_position += velocity * dt
	# Kick
	velocity += ACCEL * dt/2 * dir

func pick_spot_around_player():
	var center = player.global_position
	var distance = 60

	var angle = get_randf(0, 2*PI)

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
			print_debug("ATTACKING")
			setState(State.SURROUND)

func _on_PlayerEnteredArena(body):
	print("PLAYER ENTERED FIGHT ZONE")
	if(agressivity >= TRESHOLD):
		setState(State.SURROUND)

func _on_PlayerExitedArena(body):
	print("PLAYER EXITED FIGHT ZONE")
	setState(State.HAPPY)
