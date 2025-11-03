class_name EventBuilder
extends RefCounted

var _event: EventNode

func _init():
	_event = EventNode.new()

func add_text(text: String) -> EventBuilder:
	_event.add_node(TextNode.new(text))
	return self

func add_image(path: String) -> EventBuilder:
	_event.add_node(ImageNode.new(path))
	return self

func add_choice(text: String, next_event_id: String) -> EventBuilder:
	_event.add_node(ChoiceNode.new(text, next_event_id))
	return self

func build() -> EventNode:
	return _event
