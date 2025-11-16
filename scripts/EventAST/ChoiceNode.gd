extends EventNode
class_name ChoiceNode

const type = "choice"
const text_key = "text"
const choice_key = "choice"

func _init(text: String, choice: String):
	super (type)
	set_content(text_key, text)
	set_content(choice_key, choice)

func get_text() -> String:
	return get_content(text_key)

func set_text(text: String):
	set_content(text_key, text)
