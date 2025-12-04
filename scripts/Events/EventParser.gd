extends Node
class_name EventParser

const EVENT_EXTENSION: String = ".evt"
const id_key: String = "id"
const content_key: String = "content"

func load_from_dir(path: String) -> Dictionary:
	var dir = DirAccess.open(path)
	var events = {}
	if dir == null:
		Logger.error("Can't open folder '%s' due to <%i>" % [path, DirAccess.get_open_error()])
		return events
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.to_lower().ends_with(EVENT_EXTENSION):
			var filepath = dir.get_current_dir() + "/" + fname
			if FileAccess.file_exists(filepath):
				var data = YAML.parse_file(filepath)
				if data and data.has(id_key):
					events[data.id] = _build_event_from_data(data)
		fname = dir.get_next()
	dir.list_dir_end()
	return events

func _build_event_from_data(data: Dictionary) -> EventBuilder:
	var b = EventBuilder.new()
	if data.has(id_key):
		b.set_identifier(data.id)
	for node in data.get(content_key):
		match node.type:
			TextNode.type:
				b.add_paragraph(node.get(TextNode.text_key))
			ImageNode.type:
				b.add_image(node.get(ImageNode.resource_path))
			ChoiceNode.type:
				b.add_choice(node.get(ChoiceNode.text_key), node.get(ChoiceNode.choice_key))
			_:
				Logger.warning("Unknown node type: %s" % str(node.type))
	return b
