extends EventNode
class_name ChoiceNode

const type = "choice"
const text_key = "text"

func _init(text: String, choice: String):
	super (type)
	set_content(text_key, text)

func get_text() -> String:
	return get_content(text_key)

func set_text(text: String):
	set_content(text_key, text)
