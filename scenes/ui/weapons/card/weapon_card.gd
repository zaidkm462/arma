extends Button

var data:SingleWeapon = null
var store = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
		$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Panel/Label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Panel/Icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup(weapon:SingleWeapon)->void:
	data = weapon
	var label = $Panel/Label
	label.text = weapon.name
	#Label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_KEEP_SIZE)
	if weapon.purchased : $Panel/Icon.texture = weapon.icon
	


func _on_pressed() -> void:
	store.select(data.id)
	$Panel.add_theme_stylebox_override("panel", store.weapon_slct_style_box)

func deselect() -> void:
	$Panel.add_theme_stylebox_override("panel", store.weapon_dslct_style_box)
	 
