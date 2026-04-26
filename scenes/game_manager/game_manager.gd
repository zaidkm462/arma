extends Node

const MAIN_MENU_SCENE := "res://scenes/ui/main_menu/control.tscn"
const GAME_SCENE := "res://scenes/main/main.tscn"
const LAB_SCENE := "res://scenes/lab/lab.tscn"
var gold_tres: GoldBase = preload("res://scenes/gold/gold.tres")



var WeaponsManager = null
var Player = null
var SpawnManager = null
var PassivesManager = null
var UpgradesManager = null
var Dash = null

var level := 1
var lvl_mul := 5
var xp := 0
var gold := 0
var time := 0

@onready var timer := $Timer

func _ready() -> void:
	timer.timeout.connect(update_time)
	

func on_game_scene_ready() -> void:
	get_tree().paused = false
	timer.start()
	Dash.update_res(xp, level * lvl_mul, level, gold)
	Dash.update_time(time)

func start_new_run() -> void:
	get_tree().paused = false
	_reset_data()
	timer.stop()
	AudioManager.play_gameplay_music()
	get_tree().change_scene_to_file(GAME_SCENE)

func _reset_data() -> void:
	Player = null
	SpawnManager = null
	WeaponsManager = null
	UpgradesManager = null
	PassivesManager = null
	Dash = null	
	level = 1
	xp = 0
	gold = 0
	time = 0

func go_to_main_menu() -> void:
	get_tree().paused = false
	timer.stop()
	_reset_data()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func go_to_lab() -> void:
	get_tree().paused = false
	timer.stop()
	_reset_data()
	AudioManager.play_menu_music()
	get_tree().change_scene_to_file(LAB_SCENE)

func eat_xp(amount:int)-> void:
	xp += amount
	AudioManager.play_gold_pickup_sound()
	if xp >= level * lvl_mul:
		level_up()
	Dash.update_res(xp, level * lvl_mul, level, gold)

func level_up() -> void:	
	get_tree().paused = true
	level += 1
	AudioManager.play_levelup_sound()
	AudioManager.gold_sound.stop()
	xp = 0
	GameManager.Dash.level_up(GameManager.UpgradesManager.get_level_up_cards())	

func update_time() -> void:
	time += 1
	Dash.update_time(time)

func eat_gold(amount:int)-> void:
	gold += amount
	AudioManager.play_gold_pickup_sound()
	Dash.update_res(xp, level * lvl_mul, level, gold)

func lose_game() -> void:
	AudioManager.stop_gameplay_music()
	alter_gold("enc", gold)
	get_tree().paused = true
	Dash.show_lose()
	

func alter_gold(type: String, amount: int) -> void:
	if type == "enc":
		gold_tres.gold_enc = amount
	else:		
		gold_tres.gold_dec = amount
	
	ResourceSaver.save(gold_tres, "res://scenes/gold/gold.tres")
		
