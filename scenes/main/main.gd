extends Node2D

func _ready() -> void:
	GameManager.on_game_scene_ready()
	GameManager.WeaponsManager.add("whip")
	GameManager.Player.init_powerups()
