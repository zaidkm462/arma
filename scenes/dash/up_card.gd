extends TextureButton

var data: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$New.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pressed.connect(clicked)

func SetUp(item: Dictionary) -> void:
	data = item
	$Icon.texture = item["icon"]
	$Name.text = item["name"]
	$Desc.text = item["desc"]
	$New.text = item["level"]
	if item["level"] != "new":
		$New.add_theme_color_override("font_color", Color(1, 1, 1))
	

func clicked() -> void:
	if data['type'] == 'weapon':
		if data['action'] == 'add': GameManager.WeaponsManager.add(data['id'])
		else: GameManager.WeaponsManager.upgrade(data['id'])
	else:
		if data['action'] == 'add': GameManager.PassivesManager.add(data['id'])
		else: GameManager.PassivesManager.upgrade(data['id'])
	GameManager.Dash.hide_level_up()	
	get_tree().paused = false

	
