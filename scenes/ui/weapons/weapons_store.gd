extends Control

@onready var weapon_card_scene: PackedScene = load("res://scenes/ui/weapons/card/weapon_card.tscn")
@onready var weapons_list: WeaponsList = load("res://scenes/weapons/resources/weapons_list.tres")


@onready var weapon_slct_style_box = StyleBoxTexture.new()
@onready var weapon_dslct_style_box = StyleBoxTexture.new()

var weapons_objects : Array[Control] = []
var selected_weapon:Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
	weapon_slct_style_box.texture = load("res://scenes/ui/weapons/card/card_sl.png")
	weapon_dslct_style_box.texture = load("res://scenes/ui/weapons/card/card_un.png")
	
	$Panel/DetailsPanel/TextureButton.pressed.connect(buy)
	
	
	for i in weapons_list.weapons:
		var weapon = weapon_card_scene.instantiate()
		weapons_objects.append(weapon)
		$Panel/GridContainer.add_child(weapon)
		weapon.store = self
		weapon.setup(i)
	
	weapons_objects[0]._on_pressed()
	

func select(id:String) -> void:
	for i in weapons_objects:
		if i.data.id == id:
			if selected_weapon: selected_weapon.deselect()
			selected_weapon = i
			update_details()
			break


func buy() -> void:
	var gold = 99999;
	if selected_weapon.data.price > gold: return
	
	for w in weapons_list.weapons:
		if w.id == selected_weapon.data.id:
			w.purchased = true
	ResourceSaver.save(weapons_list, "res://scenes/weapons/resources/weapons_list.tres")
	selected_weapon.buy()
	update_details()

func update_details() -> void:
	$Panel/DetailsPanel/Card/Label.text=selected_weapon.data.name
	var price:int = selected_weapon.data.price 
	$Panel/DetailsPanel/TextureButton/Label.text = str(price)
	if selected_weapon.data.purchased: 
		$Panel/DetailsPanel/DescLabel.text = selected_weapon.data.desc
		$Panel/DetailsPanel/Card/Icon.texture = selected_weapon.data.icon
		$Panel/DetailsPanel/TextureButton.modulate = Color(0.37, 0.37, 0.37, 1)
		$Panel/DetailsPanel/TextureButton.disabled=true
	else:
		$Panel/DetailsPanel/DescLabel.text = "Buy this Weapon to be able to see it details."
		$Panel/DetailsPanel/Card/Icon.texture = null
		$Panel/DetailsPanel/TextureButton.modulate = Color(1, 1, 1, 1)
		$Panel/DetailsPanel/TextureButton.disabled=false
		
