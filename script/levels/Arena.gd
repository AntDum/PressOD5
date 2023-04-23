extends Node2D


export (PackedScene) var enemy

signal arenaCleared

onready var spawnArea = $SpawnArea/CollisionShape2D.shape.extents
onready var upperLeft = $SpawnArea/CollisionShape2D.global_position -  spawnArea
onready var lowerRight = $SpawnArea/CollisionShape2D.global_position +  spawnArea
var remaining_mobs
var player
var aggressivity

func gen_random_spawn_point():
	var x = rand_range(upperLeft.x, lowerRight.x)
	var y = rand_range(upperLeft.y, lowerRight.y)
	print("New pos ",x,y)
	return Vector2(x, y)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	aggressivity = PlayerInfo.aggressivity
	remaining_mobs = (aggressivity / 10) + 1
	print(player)


func spawn():
	for i in range(remaining_mobs):
		var new_enemy = enemy.instance()
		add_child(new_enemy)
		new_enemy.set_player(player)
		new_enemy.global_position = gen_random_spawn_point()
		new_enemy.setAgressivity(aggressivity)
		
		$FightArea.connect("body_entered",new_enemy,"_on_PlayerEnteredArena")
		$FightArea.connect("body_exited",new_enemy,"_on_PlayerExitedArena")
		new_enemy.connect("pacified",self,"_on_mob_pacified")
		new_enemy.connect("dead",self,"_on_mob_pacified")

func _on_mob_pacified():
	remaining_mobs -= 1
	if(remaining_mobs <= 0):
		print("COUCOU")
		emit_signal("arenaCleared")



func _on_TriggerSpawnArea_body_entered(body):
	print("TRIGGER")
	spawn()
