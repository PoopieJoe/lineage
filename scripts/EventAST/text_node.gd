extends EventNode
class_name TextNode


func _init(parent: EventNode, text: String):
	super ("text", parent)
	set_content("text", text)

func get_text() -> String:
	return get_content("text")

func set_text(text: String):
	set_content("text", text)