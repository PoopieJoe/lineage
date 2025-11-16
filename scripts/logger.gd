extends Node

var target_label: RichTextLabel = null
const log_color: Color = Color.LIGHT_GRAY
const info_color: Color = Color.BLUE
const warning_color: Color = Color.ORANGE
const error_color: Color = Color.RED

func set_output(label: RichTextLabel) -> void:
	target_label = label
	label.bbcode_enabled = true

func _log(message: String, color: Color) -> void:
	if target_label:
		target_label.append_text("[color=" + color.to_html() + "]" + message + "\n")
		target_label.scroll_to_line(target_label.get_line_count() - 1)

func log(message: String) -> void:
	print(message)
	_log(message, log_color)

func info(message: String) -> void:
	print(message)
	_log(message, info_color)

func warning(message: String) -> void:
	push_warning(message)
	_log(message, warning_color)

func error(message: String) -> void:
	push_error(message)
	_log(message, error_color)
