extends ProgressBar

func set_health(current: int, maximum: int) -> void:
	max_value = maximum
	value = current
