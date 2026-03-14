extends Node

var tres_file: EnemyList = preload("res://scenes/Enemy/enemy_list.tres")
var name_scene_dic: Dictionary = {}
var alive_enemies: Array[Area2D] = []

func _ready():
	GameManager.SpawnManager = self

	for data in tres_file.enemies:
			name_scene_dic[data.name] = data.scene


func spawn(name: String, spawn_position: Vector2):
	if not name_scene_dic.has(name):
		push_error("SpawnManager: wrong id-> " + name)
		return

	var new_enemy = name_scene_dic[name].instantiate()
	new_enemy.global_position = spawn_position
	owner.get_node("Enemies").add_child(new_enemy)
	alive_enemies.append(new_enemy)
	print(name)

func kill(enemy: Area2D):
	if enemy in alive_enemies:
		alive_enemies.erase(enemy)
		enemy.queue_free()
	else:
		push_warning("SpawnManager: Enemy not found in list!")
