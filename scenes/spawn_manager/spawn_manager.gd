extends Node

var roster: EnemyList = preload("res://scenes/Enemy/enemy_list.tres")

var enemy_dictionary: Dictionary = {}

func _ready():
	GameManager.SpawnManager = self

	for data in roster.enemies:
		if data != null and data.scene != null and data.name != "":
			enemy_dictionary[data.name] = data.scene
			#print("add done: ", data.enemy_id)


func spawn(name: String, spawn_position: Vector2):
	if not enemy_dictionary.has(name):
		push_error("SpawnManager: wrong id-> " + name)
		return

	var new_enemy = enemy_dictionary[name].instantiate()
	new_enemy.global_position = spawn_position

	owner.get_node("Enemies").add_child(new_enemy)
	print(name)


func _process(delta: float) -> void:
	pass
