extends Node
class_name EventParser

const EVENT_EXTENSION: String = ".evt"

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
				if data:
					var id = fname.split(EVENT_EXTENSION)[0]
					events[id] = _build_event_from_data(id, data)
		fname = dir.get_next()
	dir.list_dir_end()
	return events

func _build_event_from_data(id: String, data: Dictionary) -> EventBuilder:
	var builder = EventBuilder.new()
	builder.set_identifier(id)
	var metadata = data.get("meta", {})
	for tag in metadata.get("tags", []):
		builder.add_tag(tag)
	builder = _build_content(builder, data)
	return builder.finalize()

func _build_content(builder: EventBuilder, data: Dictionary) -> EventBuilder:
	var content = data.get("content", [])
	for idx in content.size():
		var node = content[idx]
		if not node.has("type"):
			Logger.warning("Node %i missing 'type' field" % idx)
		var type = node.get("type") as String
		match type:
			"text":
				builder.add_paragraph(node.get("text"))
			"image":
				builder.add_image(node.get("resource_path"))
			"choice":
				builder.add_choice(node.get("text"), node.get("choice"))
			"choose":
				builder.add_choose()
			"vspace":
				builder.add_vspace(node.get("size"))
			"branch":
				builder.enter_branch(node.get("condition"))
				builder = _build_content(builder, node)
				builder.exit_branch()
			_:
				Logger.warning("Node type \"%s\" has no defined build node" % type)
	return builder
