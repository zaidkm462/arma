extends Node

var menu_music: AudioStreamPlayer
var damage_sound: AudioStreamPlayer
var dead_sound: AudioStreamPlayer
var gold_sound: AudioStreamPlayer
var levelup_sound: AudioStreamPlayer
var button_sound: AudioStreamPlayer
var gameplay_music: AudioStreamPlayer
var correct_answer: AudioStreamPlayer
var incorrect_answer: AudioStreamPlayer
var current_music_type: String = ""

func _ready():
	menu_music = AudioStreamPlayer.new()
	add_child(menu_music)
	menu_music.stream = preload("res://scenes/sounds/menu music.mp3")
	menu_music.bus = "menu"
	
	gameplay_music = AudioStreamPlayer.new()
	add_child(gameplay_music)
	gameplay_music.stream = preload("res://scenes/sounds/gameplay music.mp3")  # Your gameplay music file
	gameplay_music.bus = "gameplay"
	
	damage_sound = AudioStreamPlayer.new()
	add_child(damage_sound)
	damage_sound.bus = "damage"
	
	dead_sound = AudioStreamPlayer.new()
	add_child(dead_sound)
	dead_sound.bus = "dead"
	
	gold_sound = AudioStreamPlayer.new()
	add_child(gold_sound)
	gold_sound.bus = "gold"
	
	levelup_sound = AudioStreamPlayer.new()
	add_child(levelup_sound)
	levelup_sound.bus = "levelup"
	
	button_sound = AudioStreamPlayer.new()
	add_child(button_sound)
	button_sound.bus = "button"
	
	correct_answer = AudioStreamPlayer.new()
	add_child(correct_answer)
	correct_answer.bus = "correct"
	
	incorrect_answer = AudioStreamPlayer.new()
	add_child(incorrect_answer)
	correct_answer.bus = "incorrect"

func play_menu_music():
	if gameplay_music.playing:
		gameplay_music.stop()
	if not menu_music.playing:
		menu_music.play()
		current_music_type = "menu"

func stop_menu_music():
	if menu_music.playing:
		menu_music.stop()
		current_music_type = ""

func is_menu_music_playing() -> bool:
	return menu_music.playing and current_music_type == "menu"

func play_gameplay_music():
	if menu_music.playing:
		menu_music.stop()
	if not gameplay_music.playing:
		gameplay_music.play()

func stop_gameplay_music():
	if gameplay_music.playing:
		gameplay_music.stop()

func play_damage_sound():
	if damage_sound:
		damage_sound.stream = preload("res://scenes/sounds/damage.wav")  # Update path
		damage_sound.play()

func play_dead_sound():
	dead_sound.stream = preload("res://scenes/sounds/dead.mp3")
	dead_sound.play()

func disable_damage_sound():
	damage_sound.stop()

func play_gold_pickup_sound():
	gold_sound.stream = preload("res://scenes/sounds/pickup.mp3")
	gold_sound.play()
	
func play_levelup_sound():
	levelup_sound.stream = preload("res://scenes/sounds/level up.mp3")
	levelup_sound.play()

func play_button_sound():
	button_sound.stream = preload("res://scenes/sounds/button.mp3")
	button_sound.play()
	
func play_correct_sound():
	correct_answer.stream = preload("res://scenes/sounds/correct.mp3")
	correct_answer.play()
	
func play_incorrect_sound():
	incorrect_answer.stream = preload("res://scenes/sounds/incorrect.mp3")
	incorrect_answer.play()
