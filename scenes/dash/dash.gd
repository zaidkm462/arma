extends CanvasLayer

@onready var xp_bar:= $XPBar
@onready var level_label:= $LevelLabel
@onready var gold_label:= $GoldLabel
@onready var time_label:= $TimeLabel

@onready var lose_panel := $Lose
@onready var retry_button := $Lose/Button2
@onready var main_button := $Lose/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	retry_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	main_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	GameManager.Dash = self
	lose_panel.visible = false
	retry_button.pressed.connect(_on_retry_button_pressed)
	main_button.pressed.connect(_on_main_button_pressed)

func update_res(xp: int, max_xp: int, level: int, gold: int) -> void:
	xp_bar.max_value = max_xp
	xp_bar.value = xp
	gold_label.text = str(gold)
	level_label.text = "Lv  " + str(level)


func update_time(seconds: int) -> void:
	var minutes: int = seconds / 60
	var secs: int = seconds % 60
	time_label.text = "%02d:%02d" % [minutes, secs]

func _on_retry_button_pressed() -> void:
	GameManager.start_new_run()

func _on_main_button_pressed() -> void:
	GameManager.go_to_main_menu()


func show_lose() -> void:
	lose_panel.visible = true
