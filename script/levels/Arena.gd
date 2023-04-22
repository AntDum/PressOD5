extends Node2D


export (PackedScene) var enemy

signal arenaCleared

onready var spawnArea = $SpawnArea/CollisionShape2D.shape.extents
onready var origin = $SpawnArea/CollisionShape2D.global_position -  spawnArea
var remaining_mobs
var player
var aggressivity

func gen_random_spawn_point():
	var x = rand_range(origin.x, spawnArea.x)
	var y = rand_range(origin.y, spawnArea.y)
	return Vector2(x, y)
# Called when the node enters the scene tree for the first time.
func _ready():

	aggressivity = PlayerInfo.aggressivity
	remaining_mobs = (aggressivity / 10) + 1


func spawn():
	for i in range(remaining_mobs):
		print("Spawing mobs in arena")
		var new_enemy = enemy.instance()
		new_enemy.global_position = gen_random_spawn_point()
		new_enemy.setAgressivity(aggressivity)
		new_enemy.player = player
		add_child(new_enemy)
		$FightArea.connect("body_entered",new_enemy,"_on_PlayerEnteredArena")
		$FightArea.connect("body_exited",new_enemy,"_on_PlayerExitedArena")
		new_enemy.connect("pacified",self,"_on_mob_pacified")

func _on_mob_pacified():
	remaining_mobs -= 1
	if(remaining_mobs <= 0):
		emit_signal("arenaCleared")



func _on_TriggerSpawnArea_body_entered(body):
	print("TRIGGER")
	spawn()
