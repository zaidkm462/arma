extends RichTextLabel


@export var vertical_scrollbar_width: int = 6
@export var horizontal_scrollbar_height: int = 4

func _ready() -> void:
	_apply_thin_scrollbars()

func _apply_thin_scrollbars() -> void:
	var vbar: VScrollBar = get_v_scroll_bar()



	if vbar:
		vbar.custom_minimum_size.x = vertical_scrollbar_width

		var v_scroll := StyleBoxFlat.new()
		v_scroll.bg_color = Color(0, 0, 0, 0)
		v_scroll.content_margin_left = 0
		v_scroll.content_margin_top = 0
		v_scroll.content_margin_right = 0
		v_scroll.content_margin_bottom = 0

		var v_grabber := StyleBoxFlat.new()
		v_grabber.bg_color = Color(0.6, 0.6, 0.6, 0.9)
		v_grabber.corner_radius_top_left = 3
		v_grabber.corner_radius_top_right = 3
		v_grabber.corner_radius_bottom_left = 3
		v_grabber.corner_radius_bottom_right = 3
		v_grabber.content_margin_left = 0
		v_grabber.content_margin_top = 0
		v_grabber.content_margin_right = 0
		v_grabber.content_margin_bottom = 0

		var v_grabber_hover := v_grabber.duplicate()
		v_grabber_hover.bg_color = Color(0.8, 0.8, 0.8, 1.0)

		var v_grabber_pressed := v_grabber.duplicate()
		v_grabber_pressed.bg_color = Color(1.0, 1.0, 1.0, 1.0)

		vbar.add_theme_stylebox_override("scroll", v_scroll)
		vbar.add_theme_stylebox_override("scroll_focus", v_scroll)
		vbar.add_theme_stylebox_override("grabber", v_grabber)
		vbar.add_theme_stylebox_override("grabber_highlight", v_grabber_hover)
		vbar.add_theme_stylebox_override("grabber_pressed", v_grabber_pressed)
