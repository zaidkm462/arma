extends Control

var store:Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_menu_music()
	$GoldPnl/Label.text = "Gold Enc: "+str(GameManager.gold_tres.gold_enc) + " G."
	$GoldPnl2/Label.text = "Gold Dec: "+str(GameManager.gold_tres.gold_dec) + " G."
	pass # Replace with function body.


func _on_items_btn_pressed() -> void:
	AudioManager.play_button_sound()
	$Overlay.show()
	store = load("res://scenes/ui/items/items_store.tscn").instantiate()
	get_tree().current_scene.add_child(store)



func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:			
			$Overlay.hide()
			store.queue_free()

func _on_weapons_btn_pressed() -> void:
	AudioManager.play_button_sound()
	$Overlay.show()
	store = load("res://scenes/ui/weapons/weapons_store.tscn").instantiate()
	get_tree().current_scene.add_child(store)

func _on_play_btn_pressed() -> void:
	AudioManager.play_button_sound()
	AudioManager.stop_menu_music()
	$Overlay.show()
	await get_tree().process_frame
	await get_tree().process_frame
	GameManager.start_new_run()

func _on_lab_btn_pressed() -> void:
	AudioManager.play_button_sound()
	$Overlay.show()
	await get_tree().process_frame
	await get_tree().process_frame
	GameManager.go_to_lab()


	
