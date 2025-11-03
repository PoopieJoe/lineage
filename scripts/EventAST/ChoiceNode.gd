extends EventNode
class_name ChoiceNode

var text: String
var next_event_id: String
const type = "choice"

func _init(_text: String, _next_event_id: String):
	super(type)
	text = _text
	next_event_id = _next_event_id
