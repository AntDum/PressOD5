extends KinematicBody2D

export (float) var SPEED = 30
export (float) var ACCEL = 10
const TRESHOLD = 1

signal pacified

enum State {
	HAPPY,			# Ignores the player, moves randomly
	SURROUND,		# Gets close to the player and periodically CHARGE
	CHARGE,
}

export (State) var state = State.HAPPY

var agressivity = 0.0
var happy_center = position

var velocity = Vector2(0.0, 0.0)
var randGen = RandomNumberGenerator.new()

export (float) var change_target_every = 1.0
var time_since_target_change = change_target_every + 0.1
var current_target

var player

func setAgressivity(value):
	agressivity = value
	if value >= TRESHOLD:
		setState(State.SURROUND)
	else:
		setState(State.HAPPY)

func setState(newState):
	state = newState
	match state:
		State.HAPPY:
			current_target = pick_spot_around_player()
			happy_center = position
			time_since_target_change = 0
		State.SURROUND:
			current_target = pick_happy_spot()
			time_since_target_change = 0
		State.CHARGE:
			pass

# Moves towards target, dt is the time step, leapfrog (kdk) integration
func move(target, dt):
	var dir = (position - target).normalized()
	# Kick
	velocity += ACCEL * dt/2 * dir
	# Cap
	var vnorm = velocity.length()
	if vnorm > SPEED:
		velocity *= SPEED/vnorm
	# Drift
	position += velocity * dt
	# Kick
	velocity += ACCEL * dt/2 * dir

func pick_spot_around_player():
	var center = player.position
	var distance = 40
	
	randGen.randomize()
	var rng = randGen.randf()
	var angle = 2 * PI * rng
	
	var x = center.x + cos(angle) * distance
	var y = center.y + sin(angle) * distance
	
	return Vector2(x, y)
	
func setPosition(newPosition):
	happy_center = newPosition
	position = newPosition

func pick_happy_spot():
	var distance = 40
	
	randGen.randomize()
	var rng = randGen.randf()
	var angle = 2 * PI * rng
	
	var x = happy_center.x + cos(angle) * distance
	var y = happy_center.y + sin(angle) * distance
	
	return Vector2(x, y)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	time_since_target_change += delta
	match state:
		State.SURROUND:
			if time_since_target_change > change_target_every:
				current_target = pick_spot_around_player()
				time_since_target_change = 0
			move(current_target, delta)
		State.HAPPY:
			if time_since_target_change > change_target_every:
				current_target = pick_happy_spot()
				time_since_target_change = 0
			move(current_target, delta)
		State.CHARGE:
			pass
			
func _on_PlayerEnteredArena(body):
	print("PLAYER ENTERED FIGHT ZONE")
	if(agressivity >= TRESHOLD):
		setState(State.SURROUND)
		
func _on_PlayerExitedArena(body):
	print("PLAYER EXITED FIGHT ZONE")
	setState(State.HAPPY)
