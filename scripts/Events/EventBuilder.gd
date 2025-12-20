class_name EventBuilder
extends RefCounted

var _event: EventRootNode
var _section: SectionNode
var _branch: EventNode
var _current_section_index: int = 0
var finalized: bool = false

func _init():
	_event = EventRootNode.new()
	add_section()

func add_tag(tag: String) -> EventBuilder:
	_event.add_tag(tag)
	return self

func set_identifier(id: String) -> EventBuilder:
	_event.set_identifier(id)
	return self

func get_identifier() -> String:
	return _event.get_identifier()

func add_section() -> EventBuilder:
	_section = SectionNode.new()
	_branch = _section
	_event.add_child(_section)
	return self

## Attempts to append the text to previous paragraph, if there is no running 
## paragraph, creates a new one
func add_text(text: String) -> EventBuilder:
	var last_event: TextNode = null
	if not _branch.get_children().is_empty():
		last_event = _branch.get_children().back() as TextNode
		
	if last_event != null:
		last_event.set_text(last_event.get_text() + text)
	else:
		_branch.add_child(TextNode.new(text))
	return self

## Forces creation of a new paragraph with the given text, even if there 
## already is a running paragraph
func add_paragraph(text: String) -> EventBuilder:
	_branch.add_child(TextNode.new(text))
	return self
	
func add_image(path: String) -> EventBuilder:
	_branch.add_child(ImageNode.new(path))
	return self

func add_choice(text: String, next_event_id: String) -> EventBuilder:
	_branch.add_child(ChoiceNode.new(text, next_event_id))
	return self

func add_vspace(size: int) -> EventBuilder:
	_branch.add_child(VSpaceNode.new(size))
	return self

func add_header(text: String) -> EventBuilder:
	get_sections()[0].add_child(TextNode.new(text), 0)
	return self

func enter_branch(condition: String) -> EventBuilder:
	_branch = BranchNode.new(condition)
	_section.add_child(_branch)
	return self

func exit_branch() -> EventBuilder:
	_branch = _section
	return self

func get_number_of_sections() -> int:
	return get_sections().size()

func get_sections() -> Array[SectionNode]:
	var sections: Array[SectionNode] = []
	for child in _event.get_children():
		if child.get_type() == "section":
			sections.append(child)
	return sections

func build_sections_start(_state: WorldState) -> SectionNode:
	if not finalized:
		Logger.error("Event not finalized, nothing to build")
		return SectionNode.new()

	_section = get_sections()[_current_section_index]
	return _section.build(_state)

func build_next_section(_state: WorldState) -> SectionNode:
	_current_section_index += 1
	if _current_section_index >= get_number_of_sections():
		Logger.error("No next section, nothing to build")
		return SectionNode.new()
	_section = get_sections()[_current_section_index]
	return _section.build(_state)

func finalize() -> EventBuilder:
	if not finalized:
		if _event.has_identifier() == false:
			_event.set_identifier("EVENT_%08X" % randi())
		finalized = true
	else:
		Logger.warning("EventBuilder.finalize() should not be called multiple times")
	return self