extends Node

@export var weapons_list: WeaponsList = preload("res://scenes/weapons/resources/weapons_list.tres")
var purchased_weapons: Dictionary[String, SingleWeapon] = {}
var game_weapons: Dictionary[String, Area2D] = {}

func _ready() -> void:
	GameManager.WeaponsManager = self
	for weapon in weapons_list.weapons:
		if weapon.purchased:
			purchased_weapons[weapon.id] = weapon

func add(id: String) -> void:
	if not purchased_weapons.has(id):
		push_error("WeaponManager: wrong weapon name -> " + id)
		return
	if game_weapons.has(id): return
	
	var weapons_holder = GameManager.Player.get_node("Weapons")
	var new_weapon = purchased_weapons[id].scene.instantiate()
	weapons_holder.add_child(new_weapon)
	game_weapons[id] = new_weapon

func upgrade(id: String) -> void:
	if not game_weapons.has(id): return
	
	var weapon_obj:= game_weapons[id]
	var weapon_data := purchased_weapons[id]
	
	var next_level:int = weapon_obj.level+1
	if next_level > len(weapon_data.levels): return
	
	var level: WeaponLevel = weapon_data.levels[weapon_obj.level]
	
	var value := 0.0
	if level.is_percentage: value = weapon_obj[level.stat] * level.value / 100 
	else: value = level.value
	
	weapon_obj.upgrade(level.stat, value)
	weapon_obj.level += 1
	
	print(level.desc)
	print(weapon_obj[level.stat])

	
	
	
