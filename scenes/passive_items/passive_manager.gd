extends Node

@export var items_list: PassiveItemsList = preload("res://scenes/passive_items/passive_items_list.tres")
var purchased_items: Dictionary[String, PassiveItem] = {}
var game_items: Dictionary[String, PassiveItem] = {}

func _ready() -> void:
	GameManager.PassivesManager = self
	for item in items_list.items:
		if item.rank > 0:
			purchased_items[item.id] = item

func add(id: String) -> void:
	if not purchased_items.has(id):
		push_error("PassivesManager: wrong item Id -> " + id)
		return
	if game_items.has(id): return	
	
	game_items[id] = purchased_items[id].duplicate()
	GameManager.Player.update_powerups(game_items[id].stat, game_items[id].base_price)

func upgrade(id: String) -> void:
	if not game_items.has(id): return
	game_items[id].level += 1
	GameManager.Player.update_powerups(game_items[id].stat, game_items[id].base_price)
	
	

	
	
	
