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

var velocity = Vector2(0.0, 0.0)
var randGen = RandomNumberGenerator.new()

var time_since_target_change = 2.1
var change_target_every = 2.0
var current_target

var player

func setAgressivity(value):
	agressivity = value
	if value >= TRESHOLD:
		state = State.SURROUND

# Moves towards target, dt is the time step, leapfrog (kdk) integration
func move(target, dt):
	var dir = (global_position - target).normalized()
	# Kick
	velocity += ACCEL * dt/2
	# Cap
	var vnorm = velocity.norm()
	if vnorm > SPEED:
		velocity *= SPEED/vnorm
	# Drift
	position += velocity * dt
	# Kick
	velocity += ACCEL * dt/2

func jump_around(distance):
	randGen.randomize()
	var rng = randGen.randf()
	var angle = 2 * PI * rng
	
	var x = cos(angle) * distance
	var y = sin(angle) * distance
	

func pick_spot_around_player():
	var center = player.global_position
	var distance = 40
	
	randGen.randomize()
	var rng = randGen.randf()
	var angle = 2 * PI * rng
	
	var x = center + cos(angle) * distance
	var y = center + sin(angle) * distance
	
	return Vector2(x, y)
	
func pick_spot_around_self():
	var center = position
	var distance = 40
	
	randGen.randomize()
	var rng = randGen.randf()
	var angle = 2 * PI * rng
	
	var x = center + cos(angle) * distance
	var y = center + sin(angle) * distance
	
	return Vector2(x, y)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	match state:
		State.SURROUND:
			if time_since_target_change > change_target_every:
				current_target = pick_spot_around_player()
			move(current_target, delta)
		State.HAPPY:
			if time_since_target_change > change_target_every:
				current_target = pick_spot_around_self()
			move(current_target, delta)
		State.CHARGE:
			pass
			
			
			
			
			
			
			
			
