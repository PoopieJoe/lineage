extends EventNode
class_name ChoiceNode

func _init(parent: EventNode, text: String, choice: String):
	super ("choice", parent)
	set_content("text", text)
	set_content("choice", choice)

func get_text() -> String:
	return get_content("text")

func set_text(text: String):
	set_content("text", text)

func get_choice() -> String:
	return get_content("choice")