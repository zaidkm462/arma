extends Area2D

@export var xp_amount: int = 1
@onready var animated_sprite := $AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animated_sprite.play("default")

func _on_body_entered(body: Node) -> void:
		GameManager.eat_xp(xp_amount)
		queue_free()
