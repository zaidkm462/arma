extends Area2D

var projectile_scene: PackedScene = preload("res://scenes/weapons/magical_wand/magic_projectile.tscn")

var amount: int = 1
var cool_down: float = 3
var duration: float = 2.0
var area_scale: float = 1.7
var damage: int = 1
var pass_through: int = 1
var level: int = 1

var firing:= false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var cool_down_timer: Timer = $CoolDownTimer
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D;

func _ready() -> void:
	position = Vector2.ZERO
	

	#collision_shape.shape.radius = area_radius
	area_entered.connect(ar_entered)
	cool_down_timer.wait_time = cool_down
	cool_down_timer.timeout.connect(fire)
	cool_down_timer.start()
	
	
	animation.animation_finished.connect(hide_animation)
	hide_animation()

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
	firing = true
	if GameManager.Player.animated_sprite.flip_h:
		animation.position.x = -35
		collision_shape.position.x = -35
	else:
		animation.position.x = 35
		collision_shape.position.x = 35
		
	#collision_shape.set_deferred("disabled", false)
	animation.show()
	animation.play("default")
	var en := get_overlapping_areas()
	print(len(en))
	for e in en:		
		if e.is_in_group("enemy"):
			e.damage_enemy(damage)
	
func hide_animation() -> void:
	#collision_shape.set_deferred("disabled", true)
	firing = false
	animation.hide()

func ar_entered(e) -> void:	
	if not firing: return
	if e.is_in_group("enemy"):
		e.damage_enemy(damage)
	
