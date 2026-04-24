extends RefCounted
const AUTH_TOKEN := "my-very-secret-lab-token"

const API_BASE_URL := "http://127.0.0.1:8000"

# Default rank loaded when the lab scene opens.
const DEFAULT_RANK := 8

# The runner tries these commands in order until one works.
static func get_python_commands() -> Array[String]:
	return ["python", "py"]
