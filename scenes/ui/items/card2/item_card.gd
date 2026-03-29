extends Button

var data:PassiveItem = null
var store = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
		$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Panel/Label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Panel/Icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Panel/HBoxContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup(item:PassiveItem)->void:
	data = item
	var label = $Panel/Label
	label.text = item.name
	#Label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_KEEP_SIZE)
	
	
	$Panel/Icon.texture = item.icon
	var chk_texture := load("res://scenes/ui/items/card2/checked.png")
	var unchk_texture :=  load("res://scenes/ui/items/card2/unchecked.png")
	for i in range(item.max_rank):
		var rank = TextureRect.new()
		rank.size_flags_vertical =Control.SIZE_SHRINK_CENTER
		
		if i < item.rank:
			rank.texture = chk_texture
		else:
			rank.texture = unchk_texture
		$Panel/HBoxContainer.add_child(rank)
		


func _on_pressed() -> void:
	store.select(data.id)
	$Panel.add_theme_stylebox_override("panel", store.item_slct_style_box)

func deselect() -> void:
	$Panel.add_theme_stylebox_override("panel", store.item_dslct_style_box)
	 
