extends EventNode
class_name TextNode

var content: String
const type = "text"

func _init(_content: String):
	super(type)
	content = _content
