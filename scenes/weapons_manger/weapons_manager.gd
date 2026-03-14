extends Node

@export var weapons_list: WeaponsList = preload("res://scenes/weapon/resources/weapons_list.tres")
var name_scene_dic: Dictionary = {}
var current_weapons: Array[Node2D] = []

func _ready() -> void:
	for weapon_data in weapons_list.weapons:
		name_scene_dic[weapon_data.name] = weapon_data.scene

func add(name: String) -> void:
	if not name_scene_dic.has(name):
		push_error("WeaponManager: wrong weapon name -> " + name)
		return

	var new_weapon = name_scene_dic[name].instantiate()
	owner.get_node("Weapons").add_child(new_weapon)
	current_weapons.append(new_weapon)
