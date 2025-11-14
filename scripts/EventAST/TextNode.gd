extends EventNode
class_name TextNode

const type = "text"
const text_key = "text"

func _init(text: String):
	super (type)
	set_content(text_key, text)

func get_text() -> String:
	return get_content(text_key)

func set_text(text: String):
	set_content(text_key, text)