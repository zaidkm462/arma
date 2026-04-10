extends Area2D

@export var speed: float = 150

var target: Area2D = null
var damage_amount: int = 1
var direction: Vector2 = Vector2.ZERO 
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var animated_sprite:= $AnimatedSprite2D

func setup(enemy: Area2D, damage_value: int) -> void:
	target = enemy
	damage_amount = damage_value
	
	if target != null and is_instance_valid(target):
		direction = (target.global_position - global_position).normalized()
		look_at(target.global_position)


func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

	if not screen_notifier.screen_exited.is_connected(_on_screen_exited):
		screen_notifier.screen_exited.connect(_on_screen_exited)
	
	animated_sprite.animation_finished.connect(queue_free)
	
	animated_sprite.play("default")


func _physics_process(delta: float) -> void:
	if animated_sprite.animation == "explode":
		if target != null and is_instance_valid(target):
			global_position = target.global_position
			global_position.y -= 5
		return

	global_position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		target = area
		area.damage_enemy(damage_amount)
			
		animated_sprite.apply_scale(Vector2(0.7, 0.7))
		animated_sprite.global_rotation = 0
		animated_sprite.play("explode")
		
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)


func _on_screen_exited() -> void:
	queue_free()
