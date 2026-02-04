class_name EventBuilder
extends RefCounted

var _event: EventRootNode
var _main_branch: BranchNode
var _branch: BranchNode
var _current_build_node: EventNode
var finalized: bool = false

func _init():
	_event = EventRootNode.new()
	_main_branch = BranchNode.new(_event)
	_branch = _main_branch
	_event.add_child(_main_branch)

func add_tag(tag: String) -> EventBuilder:
	_event.add_tag(tag)
	return self

func set_identifier(id: String) -> EventBuilder:
	_event.set_identifier(id)
	return self

func get_identifier() -> String:
	return _event.get_identifier()

## Attempts to append the text to previous paragraph, if there is no running 
## paragraph, creates a new one
func add_text(text: String) -> EventBuilder:
	var last_event: TextNode = null
	if not _branch.get_children().is_empty():
		last_event = _branch.get_children().back() as TextNode
		
	if last_event != null:
		last_event.set_text(last_event.get_text() + text)
	else:
		_branch.extend(TextNode.new(_branch, text))
	return self

## Forces creation of a new paragraph with the given text, even if there 
## already is a running paragraph
func add_paragraph(text: String) -> EventBuilder:
	_branch.extend(TextNode.new(_branch, text))
	return self
	
func add_image(path: String) -> EventBuilder:
	_branch.extend(ImageNode.new(_branch, path))
	return self

func add_choice(text: String, next_event_id: String) -> EventBuilder:
	_branch.extend(_ChoiceNode.new(_branch, text, next_event_id))
	return self

func add_choose() -> EventBuilder:
	_branch.extend(_ChooseNode.new(_branch))
	return self

func add_vspace(size: int) -> EventBuilder:
	_branch.extend(VSpaceNode.new(_branch, size))
	return self

func add_header(text: String) -> EventBuilder:
	_main_branch.add_child(TextNode.new(_main_branch, text), 0)
	return self

func enter_branch(condition: String) -> EventBuilder:
	var new_branch = BranchNode.new(_branch, condition)
	_branch.add_child(new_branch)
	_branch = new_branch
	return self

func exit_branch() -> EventBuilder:
	_branch = _branch.get_parent_branch()
	return self

func build_sections_start(_state: WorldState) -> Array[EventNode]:
	if not finalized:
		Logger.error("Event not finalized, nothing to build")
		return []
	_current_build_node = _main_branch
	Logger.debug("Node: " + _current_build_node.as_json())
	return build_next_section(_state)

func build_next_section(_state: WorldState) -> Array[EventNode]:
	# Traverse main branch until a choose node is found, or the end is reached
	var out_nodes = []
	while true:
		if _current_build_node == null:
			break
		Logger.debug("Node: " + _current_build_node.as_json())
		if _current_build_node is _ChooseNode:
			break
		elif _current_build_node is BranchNode:
			if _current_build_node.evaluate(_state):
				_current_build_node = _current_build_node.get_children().front()
		else:
			var built_node = _current_build_node.build(_state)
			if built_node != null:
				out_nodes.append(built_node)
			_current_build_node = _current_build_node.get_next_node()
	return out_nodes

func finalize() -> EventBuilder:
	if not finalized:
		if _event.has_identifier() == false:
			_event.set_identifier("EVENT_%08X" % randi())
		finalized = true
	else:
		Logger.warning("EventBuilder.finalize() should not be called multiple times")
	return self
