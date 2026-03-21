extends Node

var Player = null
var SpawnManager = null
var WeaponsManager = null
var CardsManager = null
var Dash = null

var level := 1
var lvl_mul := 5
var xp := 0
var gold := 0
var time := 0

@onready var timer := $Timer

func _ready() -> void:
	timer.timeout.connect(update_time)
	timer.start()
	

func eat_xp(amount:int)-> void:
	xp += amount
	if xp >= level * lvl_mul:
		level_up()
	Dash.update_res(xp, level * lvl_mul, level, gold)

func level_up() -> void:
	level += 1
	xp = 0

func update_time() -> void:
	time += 1
	Dash.update_time(time)

func eat_gold(amount:int)-> void:
	gold += amount
	Dash.update_res(xp, level * lvl_mul, level, gold)

func lose_game() -> void:
	get_tree().paused = true
	Dash.show_lose()
