extends Control

@onready var item_scene: PackedScene = load("res://scenes/ui/items/card2/item_card.tscn")
@onready var items_list: PassiveItemsList = load("res://scenes/passive_items/passive_items_list.tres")


@onready var item_slct_style_box = StyleBoxTexture.new()
@onready var item_dslct_style_box = StyleBoxTexture.new()

var items_objects : Array[Control] = []
var selected_item:Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
	item_slct_style_box.texture = load("res://scenes/ui/items/card2/sframe.png")
	item_dslct_style_box.texture = load("res://scenes/ui/items/card2/frame.png")

	for i in items_list.items:
		var item = item_scene.instantiate()
		items_objects.append(item)
		$Panel/GridContainer.add_child(item)
		item.store = self
		item.setup(i)
	
	items_objects[0]._on_pressed()
	

func select(id:String) -> void:
	for i in items_objects:
		if i.data.id == id:
			if selected_item: selected_item.deselect()
			selected_item = i
			update_details()
			break

func update_details() -> void:
	$Panel/DetailsPanel/Card/Label.text=selected_item.data.name
	$Panel/DetailsPanel/DescLabel.text = selected_item.data.description
	$Panel/DetailsPanel/Card/Icon.texture = selected_item.data.icon
	var price:int = selected_item.data.base_price if selected_item.data.rank == 0 else selected_item.data.base_price*selected_item.data.rank
	$Panel/DetailsPanel/TextureButton/Label.text = str(price)
