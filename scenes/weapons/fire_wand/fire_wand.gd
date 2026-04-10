extends Area2D

var projectile_scene: PackedScene = preload("res://scenes/weapons/fire_wand/fire_projectile.tscn")

var amount: int = 1
var cool_down: float = 1.0
var duration: float = 2.0
var area_radius: int = 300
var damage: int = 1
var pass_through: int = 1
var level: int = 1

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var cool_down_timer: Timer = $CoolDownTimer

func _ready() -> void:
	position = Vector2.ZERO
	collision_shape.shape.radius = area_radius

	cool_down_timer.wait_time = cool_down
	cool_down_timer.timeout.connect(fire)
	cool_down_timer.start()

func upgrade(stat: String, value: float) -> void:
	if stat == "amount": amount += int(value)
	elif stat == "pass_through": pass_through += int(value)
	elif stat == "damage": damage+= int(value)
	elif stat == "duration": duration += value
	elif stat == "area":
		area_radius += int(value)	
		collision_shape.shape.radius = area_radius
	elif stat == "cool_down":
		cool_down += value	
		cool_down_timer.wait_time = cool_down
		cool_down_timer.start()

func get_random_enemies(n: int) -> Array:
	var valid_enemies: Array = []
	var overlapped_areas := get_overlapping_areas()

	for area in overlapped_areas:
		if area != null and is_instance_valid(area) and area.has_method("damage_enemy"):
			valid_enemies.append(area)

	valid_enemies.shuffle()

	if valid_enemies.size() > n:
		return valid_enemies.slice(0, n)
	
	return valid_enemies


func fire() -> void:	
	var targets := get_random_enemies(amount)
	
	if targets.is_empty(): return
	var projectiles_parent = get_tree().current_scene.get_node("Projectiles")

	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy): continue

		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position

		if projectile.has_method("setup"):
			projectile.setup(enemy, damage)

		projectiles_parent.add_child(projectile)
