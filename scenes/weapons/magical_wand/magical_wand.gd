extends Area2D

var projectile_scene: PackedScene = preload("res://scenes/weapons/magical_wand/magic_projectile.tscn")

var amount: int = 1
var cool_down: float = 1.0
var duration: float = 2.0
var area_radius: int = 150
var damage_amount: int = 1

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var cool_down_timer: Timer = $CoolDownTimer

func _ready() -> void:
	position = Vector2.ZERO
	

	collision_shape.shape.radius = area_radius

	cool_down_timer.wait_time = cool_down
	cool_down_timer.timeout.connect(fire)
	cool_down_timer.start()


func get_close_enemies(n: int) -> Array:
	var enemies: Array = []
	var overlapped_areas := get_overlapping_areas()

	for area in overlapped_areas:
		if area == null or not is_instance_valid(area):
			continue
		enemies.append(area)

	enemies.sort_custom(func(a, b):
		return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position)
	)

	if enemies.size() > n:
		enemies = enemies.slice(0, n)

	return enemies


func fire() -> void:
	var targets := get_close_enemies(amount)
	if targets.is_empty(): return

	var projectiles_parent = get_tree().current_scene.get_node("Projectiles")

	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy): 	continue

		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position

		if projectile.has_method("setup"):
			projectile.setup(enemy, damage_amount)

		projectiles_parent.add_child(projectile)
