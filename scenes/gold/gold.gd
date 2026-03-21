extends Area2D

@export var gold_amount: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
		GameManager.eat_gold(gold_amount)
		queue_free()
