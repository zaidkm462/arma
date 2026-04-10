extends Node

var spawn_interval: float = 0.3
var max_alive_enemies: int = 20

var tres_file: EnemyList = preload("res://scenes/Enemy/enemy_list.tres")
var name_scene_dic: Dictionary = {}
var enemy_names: Array[String] = []
var alive_enemies: Array[Area2D] = []

@onready var spawn_timer: Timer = $SpawnTimer


func _ready():
	GameManager.SpawnManager = self
	randomize()

	for data in tres_file.enemies:
		name_scene_dic[data.name] = data.scene
		enemy_names.append(data.name)

	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()


func _on_spawn_timer_timeout():
	#return
	if alive_enemies.size() >= max_alive_enemies:
		return

	var enemy_name: String = enemy_names.pick_random()
	var spawn_position: Vector2 = get_random_spawn_position()
	spawn(enemy_name, spawn_position)


func get_random_spawn_position() -> Vector2:
	var camera: Camera2D = GameManager.Player.get_node("Camera2D")
	var center: Vector2 = camera.get_screen_center_position()
	var visible_size: Vector2 = get_viewport().get_visible_rect().size * camera.zoom
	var radius: float = visible_size.length() * 0.5 - 50

	var angle: float = randf_range(0.0, TAU)
	var dir: Vector2 = Vector2.RIGHT.rotated(angle)

	return center + dir * radius


func spawn(name: String, spawn_position: Vector2):
	if not name_scene_dic.has(name):
		push_error("SpawnManager: wrong id-> " + name)
		return

	var new_enemy = name_scene_dic[name].instantiate()
	new_enemy.global_position = spawn_position
	get_tree().current_scene.get_node("Enemies").add_child(new_enemy)
	alive_enemies.append(new_enemy)


func kill(enemy: Area2D):
	if enemy in alive_enemies:
		alive_enemies.erase(enemy)
		enemy.queue_free()
	else:
		push_warning("SpawnManager: Enemy not found in list!")
