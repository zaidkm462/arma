extends Control

const LabConfig = preload("res://scenes/lab/lab_config.gd")
const PLACEHOLDER_TOKEN := "PASTE_ACCESS_TOKEN_HERE"
const STARTER_CODE := "# Write your Python solution here\n"

@onready var description_label: RichTextLabel = $desc/MarginContainer/RichTextLabel
@onready var output_label: RichTextLabel = $output/MarginContainer/RichTextLabel
@onready var code_editor: CodeEdit = $Terminal/MarginContainer/CodeEdit
@onready var auth_label: Label = $TextureButton/Label

var current_rank: int = LabConfig.DEFAULT_RANK
var current_problem: Dictionary = {}
var _request: HTTPRequest

func _ready() -> void:
	_request = HTTPRequest.new()
	add_child(_request)

	_connect_ui()
	_update_auth_status()
	_prepare_editor()
	_load_problem(false)

func _connect_ui() -> void:
	$run.pressed.connect(_on_run_pressed)
	$submit.pressed.connect(_on_submit_pressed)
	$HBoxContainer/TextureButton.pressed.connect(_on_get_problem_pressed)
	$HBoxContainer/TextureButton2.pressed.connect(_on_replace_problem_pressed)
	$HBoxContainer/TextureButton3.pressed.connect(_on_view_solved_pressed)

	$title/TextureButton.pressed.connect(_on_back_pressed)
	$title/TextureButton2.pressed.connect(_on_back_pressed)
	$title/TextureButton3.pressed.connect(_on_back_pressed)

	var rank_buttons: Array = $Ranks/VBoxContainer.get_children()
	var rank_value: int = 8
	for button in rank_buttons:
		if button is TextureButton:
			button.pressed.connect(_on_rank_selected.bind(rank_value))
			if rank_value == current_rank:
				button.button_pressed = true
		rank_value -= 1

func _update_auth_status() -> void:
	if _has_token():
		auth_label.text = "Authorization: Manual Token"
	else:
		auth_label.text = "Authorization: Token Missing"
		_set_output_text("Paste a bearer token in res://scenes/lab/lab_config.gd before using the API buttons.")

func _prepare_editor() -> void:
	if code_editor.text.strip_edges().is_empty() or code_editor.text.find("your code here") != -1:
		code_editor.text = STARTER_CODE

func _on_back_pressed() -> void:
	GameManager.go_to_main_menu()

func _on_rank_selected(rank: int) -> void:
	current_rank = rank
	_load_problem(false)

func _on_get_problem_pressed() -> void:
	_load_problem(false)

func _on_replace_problem_pressed() -> void:
	_load_problem(true)

func _on_view_solved_pressed() -> void:
	if not _has_token():
		_set_output_text("Missing bearer token. Paste it in res://scenes/lab/lab_config.gd.")
		return

	_set_output_text("Loading solved problems...")
	var response: Dictionary = await _request_json("/api/solved", HTTPClient.METHOD_GET)
	if not response.get("ok", false):
		_set_output_text(str(response.get("message", "Failed to load solved problems.")))
		return

	var data: Dictionary = response.get("data", {})
	var solved: Array = data.get("solved", [])
	if solved.is_empty():
		_set_output_text("No solved problems were found for this user yet.")
		return

	var lines := PackedStringArray()
	for item in solved:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		lines.append("- %s (Rank %s)" % [str(item.get("title", "Untitled")), str(item.get("rank", "?"))])

	_set_output_text("Solved Problems\n\n%s" % "\n".join(lines))

func _on_run_pressed() -> void:
	var source_code: String = code_editor.text
	if source_code.strip_edges().is_empty():
		_set_output_text("The editor is empty. Write some Python code first.")
		return

	var python_command: String = _find_python_command()
	if python_command.is_empty():
		_set_output_text("No working Python command was found. Update get_python_commands() in res://scenes/lab/lab_config.gd.")
		return

	var local_temp_path := "user://lab_solution.py"
	var file := FileAccess.open(local_temp_path, FileAccess.WRITE)
	if file == null:
		_set_output_text("Failed to create the temporary Python file.")
		return

	file.store_string(source_code)
	file.close()

	var command_output: Array = []
	var exit_code: int = OS.execute(
		python_command,
		[ProjectSettings.globalize_path(local_temp_path)],
		command_output,
		true,
		false
	)

	var output_text: String = _join_output(command_output)
	if output_text.strip_edges().is_empty():
		output_text = "Process finished with exit code %d and no output." % exit_code
	else:
		output_text = "Exit code: %d\n\n%s" % [exit_code, output_text]

	_set_output_text(output_text)

func _on_submit_pressed() -> void:
	if not _has_token():
		_set_output_text("Missing bearer token. Paste it in res://scenes/lab/lab_config.gd.")
		return

	if current_problem.is_empty():
		_set_output_text("There is no loaded problem to submit against.")
		return

	var source_code: String = code_editor.text.strip_edges()
	if source_code.is_empty():
		_set_output_text("The editor is empty. Write your solution before submitting.")
		return

	_set_output_text("Submitting solution...")
	var payload := {
		"problem_id": int(current_problem.get("id", -1)),
		"solution": code_editor.text,
	}
	var response: Dictionary = await _request_json("/api/submit-solution", HTTPClient.METHOD_POST, payload)
	if not response.get("ok", false):
		_set_output_text(str(response.get("message", "Failed to submit solution.")))
		return

	var data: Dictionary = response.get("data", {})
	var feedback: String = str(data.get("feedback", "No feedback returned."))
	var accepted: bool = bool(data.get("is_correct", false))
	var status_text := "Accepted" if accepted else "Rejected"
	_set_output_text("%s\n\n%s" % [status_text, feedback])
	
	if accepted:
		var enc = GameManager.gold_tres.gold_enc
		var dec = GameManager.gold_tres.gold_dec 
		var awarded_gold: int = (8-current_rank) * 100 + 200 
		GameManager.alter_gold("dec", dec + min(enc, awarded_gold))
		GameManager.alter_gold("enc", max(0, enc-awarded_gold))

func _load_problem(replace_current: bool) -> void:
	if not _has_token():
		return

	_set_output_text("Loading problem...")
	var endpoint := "/api/problem/%d" % current_rank
	if replace_current:
		endpoint += "/replace"

	var response: Dictionary = await _request_json(endpoint, HTTPClient.METHOD_GET)
	if not response.get("ok", false):
		_set_output_text(str(response.get("message", "Failed to load the problem.")))
		return

	current_problem = response.get("data", {})
	_render_problem()
	code_editor.text = STARTER_CODE
	_set_output_text("Problem loaded successfully.")

func _render_problem() -> void:
	var title: String = _escape_bbcode(str(current_problem.get("title", "Untitled Problem")))
	var description: String = _escape_bbcode(str(current_problem.get("description", "No description provided.")))
	var rank_name: String = _escape_bbcode(str(current_problem.get("rank_name", "")))
	var rank_number: String = str(current_problem.get("rank", current_rank))
	description_label.text = "[b]%s[/b]\nRank %s - %s\n\n%s" % [title, rank_number, rank_name, description]

func _request_json(endpoint: String, method: int, payload: Dictionary = {}) -> Dictionary:
	if _request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_request.cancel_request()

	var headers := PackedStringArray(["Accept: application/json"])
	if _has_token():
		headers.append("Authorization: Bearer %s" % LabConfig.AUTH_TOKEN)

	var body := ""
	if method == HTTPClient.METHOD_POST:
		headers.append("Content-Type: application/json")
		body = JSON.stringify(payload)

	var error_code: int = _request.request(_get_base_url() + endpoint, headers, method, body)
	if error_code != OK:
		return {
			"ok": false,
			"message": "Failed to start the HTTP request. Error code: %d" % error_code,
		}

	var result: Array = await _request.request_completed
	var request_result: int = result[0]
	var response_code: int = result[1]
	var raw_body: PackedByteArray = result[3]
	var text_body: String = raw_body.get_string_from_utf8()

	if request_result != HTTPRequest.RESULT_SUCCESS:
		return {
			"ok": false,
			"message": "HTTP request failed. Result code: %d" % request_result,
		}

	var data = JSON.parse_string(text_body)
	if response_code < 200 or response_code >= 300:
		var message := "Server error: %d" % response_code
		if typeof(data) == TYPE_DICTIONARY and data.has("detail"):
			message = str(data["detail"])
		return {
			"ok": false,
			"message": message,
		}

	if typeof(data) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"message": "The server returned invalid JSON.",
		}

	return {
		"ok": true,
		"data": data,
	}

func _get_base_url() -> String:
	var base: String = LabConfig.API_BASE_URL.strip_edges()
	if base.ends_with("/"):
		base = base.left(base.length() - 1)
	return base

func _has_token() -> bool:
	return not LabConfig.AUTH_TOKEN.strip_edges().is_empty() and LabConfig.AUTH_TOKEN != PLACEHOLDER_TOKEN

func _find_python_command() -> String:
	for command in LabConfig.get_python_commands():
		var probe_output: Array = []
		var exit_code: int = OS.execute(command, ["--version"], probe_output, true, false)
		if exit_code == 0:
			return command
	return ""

func _join_output(lines: Array) -> String:
	var text_lines := PackedStringArray()
	for line in lines:
		text_lines.append(str(line))
	return "\n".join(text_lines)

func _set_output_text(text_value: String) -> void:
	output_label.text = _escape_bbcode(text_value)

func _escape_bbcode(value: String) -> String:
	return value.replace("[", "[lb]").replace("]", "[rb]")
