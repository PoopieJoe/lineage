class_name EventBuilder
extends RefCounted

var _event: EventRootNode

func _init():
	_event = EventRootNode.new()

func add_tag(tag: String) -> EventBuilder:
	_event.add_tag(tag)
	return self

func set_identifier(id: String) -> EventBuilder:
	_event.set_identifier(id)
	return self

## Attempts to append the text to previous paragraph, if there is no running 
## paragraph, creates a new one
func add_text(text: String) -> EventBuilder:
	var last_event: TextNode = null
	if not _event.get_children().is_empty():
		last_event = _event.get_children().back() as TextNode
		
	if last_event != null:
		last_event.set_text(last_event.get_text() + text)
	else:
		_event.add_child(TextNode.new(text))
	return self

## Forces creation of a new paragraph with the given text, even if there 
## already is a running paragraph
func add_paragraph(text: String) -> EventBuilder:
	_event.add_child(TextNode.new(text))
	return self
	
func add_image(path: String) -> EventBuilder:
	_event.add_child(ImageNode.new(path))
	return self

func add_choice(text: String, next_event_id: String) -> EventBuilder:
	_event.add_child(ChoiceNode.new(text, next_event_id))
	return self

func build(_state: WorldState) -> EventNode:
	if _event.has_identifier() == false:
		_event.set_identifier("EVENT_%08X" % randi())
	var headerNode = TextNode.new(
		"%s, %s %s\n " % [
			_state.read(WorldState.LOCATION_KEY), 
			_state.read(WorldState.DATE_KEY), 
			_state.read(WorldState.TIME_KEY)])
	_event.add_child(headerNode, 0)
	return _event
