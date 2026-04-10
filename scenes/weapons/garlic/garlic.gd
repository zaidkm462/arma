extends Area2D

var projectile_scene: PackedScene = preload("res://scenes/weapons/magical_wand/magic_projectile.tscn")

var amount: int = 1
var cool_down: float = 1.3
var duration: float = 2.0
var area_scale: float = 1.7
var damage: int = 5
var pass_through: int = 1
var kb: int = 10
var level: int = 1


@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var cool_down_timer: Timer = $CoolDownTimer
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D;

func _ready() -> void:
	position = Vector2.ZERO
	area_entered.connect(ar_entered)
	cool_down_timer.wait_time = cool_down
	cool_down_timer.timeout.connect(fire)
	cool_down_timer.start()
	start_opacity_flash()
	
	
func upgrade(stat: String, value: float) -> void:
	if stat == "amount": amount += int(value)
	elif stat == "pass_through": pass_through += int(value)
	elif stat == "damage": damage+= int(value)
	elif stat == "duration": duration += value
	elif stat == "area_scale":
		area_scale += value
		scale = Vector2(area_scale, area_scale)
	elif stat == "cool_down":
		cool_down += value	
		cool_down_timer.wait_time =cool_down
		cool_down_timer.start()


func fire() -> void:
	var en := get_overlapping_areas()
	for e in en:		
		if e.is_in_group("enemy"):
			e.damage_enemy(damage, 0)
	


func ar_entered(e) -> void:	
	if e.is_in_group("enemy"):
		e.damage_enemy(damage, 0)
	
func start_opacity_flash() -> void:
	var tween = create_tween()
	tween.set_loops()
	animation.modulate.a = 0.7
	tween.tween_property(animation, "modulate:a", 0.5, 0.7)
	
	tween.tween_property(animation, "modulate:a", 0.7, 0.5)
