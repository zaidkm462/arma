extends CodeEdit

@export var vertical_scrollbar_width: int = 4
@export var horizontal_scrollbar_height: int = 4

func _ready() -> void:
	_apply_thin_scrollbars()
	_apply_python_highlighting()

func _apply_thin_scrollbars() -> void:
	var vbar: VScrollBar = get_v_scroll_bar()
	var hbar: HScrollBar = get_h_scroll_bar()



	if vbar:
		vbar.custom_minimum_size.x = vertical_scrollbar_width

		var v_scroll := StyleBoxFlat.new()
		v_scroll.bg_color = Color(0, 0, 0, 0)
		v_scroll.content_margin_left = 0
		v_scroll.content_margin_top = 0
		v_scroll.content_margin_right = 0
		v_scroll.content_margin_bottom = 0

		var v_grabber := StyleBoxFlat.new()
		v_grabber.bg_color = Color(0.6, 0.6, 0.6, 0)
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

	if hbar:
		hbar.custom_minimum_size.y = horizontal_scrollbar_height

		var h_scroll := StyleBoxFlat.new()
		h_scroll.bg_color = Color(0, 0, 0, 0)
		h_scroll.content_margin_left = 0
		h_scroll.content_margin_top = 0
		h_scroll.content_margin_right = 0
		h_scroll.content_margin_bottom = 0

		var h_grabber := StyleBoxFlat.new()
		h_grabber.bg_color = Color(0.6, 0.6, 0.6, 0)
		h_grabber.corner_radius_top_left = 3
		h_grabber.corner_radius_top_right = 3
		h_grabber.corner_radius_bottom_left = 3
		h_grabber.corner_radius_bottom_right = 3
		h_grabber.content_margin_left = 0
		h_grabber.content_margin_top = 0
		h_grabber.content_margin_right = 0
		h_grabber.content_margin_bottom = 0

		var h_grabber_hover := h_grabber.duplicate()
		h_grabber_hover.bg_color = Color(0.8, 0.8, 0.8, 1.0)

		var h_grabber_pressed := h_grabber.duplicate()
		h_grabber_pressed.bg_color = Color(1.0, 1.0, 1.0, 1.0)

		hbar.add_theme_stylebox_override("scroll", h_scroll)
		hbar.add_theme_stylebox_override("scroll_focus", h_scroll)
		hbar.add_theme_stylebox_override("grabber", h_grabber)
		hbar.add_theme_stylebox_override("grabber_highlight", h_grabber_hover)
		hbar.add_theme_stylebox_override("grabber_pressed", h_grabber_pressed)
	

func _apply_python_highlighting() -> void:
	var highlighter := CodeHighlighter.new()

	syntax_highlighter = highlighter

	# keywords
	var keywords := [
		"False", "None", "True", "and", "as", "assert", "async", "await",
		"break", "class", "continue", "def", "del", "elif", "else", "except",
		"finally", "for", "from", "global", "if", "import", "in", "is",
		"lambda", "nonlocal", "not", "or", "pass", "raise", "return",
		"try", "while", "with", "yield", "match", "case"
	]

	for kw in keywords:
		highlighter.add_keyword_color(kw, Color("#ff7b72"))

	# builtins common
	var builtins := [
		"print", "len", "range", "str", "int", "float", "list", "dict",
		"set", "tuple", "bool", "input", "type", "open", "enumerate",
		"zip", "map", "filter", "sum", "min", "max", "abs", "round"
	]

	for fn in builtins:
		highlighter.add_keyword_color(fn, Color("#79c0ff"))

	# numbers / symbols / members
	highlighter.number_color = Color("#79c0ff")
	highlighter.member_variable_color = Color("#c9d1d9")
	highlighter.function_color = Color("#d2a8ff")
	highlighter.symbol_color = Color("#c9d1d9")

	# comments
	highlighter.set_number_color(Color("#79c0ff"))
	highlighter.add_color_region("#", "", Color("#8b949e"), true)

	# strings
	highlighter.add_color_region("\"", "\"", Color("#a5d6ff"), false)
	highlighter.add_color_region("'", "'", Color("#a5d6ff"), false)
	highlighter.add_color_region("\"\"\"", "\"\"\"", Color("#a5d6ff"), false)
	highlighter.add_color_region("'''", "'''", Color("#a5d6ff"), false)
