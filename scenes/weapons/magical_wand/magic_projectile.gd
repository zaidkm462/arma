extends Area2D

@export var speed: float = 150

var target: Area2D = null
var damage_amount: int = 1


@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var animated_sprite:= $AnimatedSprite2D

func setup(enemy: Area2D, damage_value: int) -> void:
	target = enemy
	damage_amount = damage_value


func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

	if not screen_notifier.screen_exited.is_connected(_on_screen_exited):
		screen_notifier.screen_exited.connect(_on_screen_exited)
	
	animated_sprite.animation_finished.connect(queue_free)

	
	animated_sprite.play("default")

func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		queue_free()
		return

	var direction := (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	


func _on_area_entered(area: Area2D) -> void:
	if area == target:
		area.damage_enemy(damage_amount)
		animated_sprite.apply_scale(Vector2(0.5, 0.5))
		animated_sprite.play("explode")
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)



func _on_screen_exited() -> void:
	queue_free()
