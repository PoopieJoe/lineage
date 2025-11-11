class_name EventBuilder
extends RefCounted

var _event: EventNode

func _init():
	_event = EventNode.new()

## Attempts to append the text to previous paragraph, if there is no running 
## paragraph, creates a new one
func add_text(text: String) -> EventBuilder:
	var last_event:TextNode = null
	if not _event.children.is_empty():
		last_event = _event.children.back() as TextNode
		
	if last_event != null:
		last_event.content += text
	else:
		_event.add_node(TextNode.new(text))
	return self

## Forces creation of a new paragraph with the given text, even if there 
## already is a running paragraph
func add_paragraph(text: String) -> EventBuilder:
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
