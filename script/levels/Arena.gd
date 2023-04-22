extends Node2D


export (PackedScene) var enemy

signal arenaCleared

onready var spawnArea = $SpawnArea/CollisionShape2D.shape.extents
onready var origin = $SpawnArea/CollisionShape2D.global_position -  spawnArea
var remaining_mobs

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
		var new_enemy = enemy.instance()
		new_enemy.place(gen_random_spawn_point())
		new_enemy.setAggressivity = aggressivity
		add_child(new_enemy)
		$FightArea/CollisionShape2D.connect("area_entered",new_enemy,"_on_PlayerEnteredArena")
		$FightArea/CollisionShape2D.connect("area_exited",new_enemy,"_on_PlayerExitedArena")
		new_enemy.connect("pacified",self,"_on_mob_pacified")

func _on_mob_pacified():
	remaining_mobs -= 1
	if(remaining_mobs <= 0):
		emit_signal("arenaCleared")


func _on_TriggerSpawnArea_area_entered(area):
	spawn()
