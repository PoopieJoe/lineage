extends Node

var target_label: RichTextLabel = null
const print_color: Color = Color.DEEP_PINK

func set_output(label: RichTextLabel) -> void:
	target_label = label
	label.bbcode_enabled = true

func log(message: String) -> void:
	if target_label:
		target_label.append_text("[color=" + print_color.to_html() + "]" + message + "\n")
		target_label.scroll_to_line(target_label.get_line_count() - 1)
	print(message)
