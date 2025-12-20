class_name EventNode
extends RefCounted

var _content: Dictionary
var _type: String

func _init(type: String):
	_type = type
	_content = Dictionary()
	set_content("children", [])

func has_children() -> bool:
	var children: Array = get_content("children")
	return children.size() > 0

func get_children() -> Array:
	return get_content("children") as Array[EventNode]

func add_child(child: EventNode, index: int = -1):
	var children = get_content("children") as Array[EventNode]
	if index == -1:
		children.append(child)
	elif index < -1 or index > children.size():
		Logger.error("Index out of bounds: %d" % index)
	else:
		children.insert(index, child)

func add_children(new_children: Array[EventNode]):
	var children: Array = get_content("children")
	children.append_array(new_children)

func set_content(key: String, value: Variant):
	_content[key] = value

func has(key: String) -> bool:
	return _content.has(key)

func get_type() -> String:
	return _type

func get_all_content() -> Dictionary:
	return _content
	
func get_content(key: String):
	return _content[key]

func build(_state: WorldState) -> EventNode:
	var children = get_children()
	for child in children:
		if child.build(_state) == null:
			children.erase(child)
	return self

func as_json() -> String:
	var json_dict = {}
	# Add type field first
	json_dict["type"] = _type
	var children_array: Array = []
	for key in _content.keys():
		var value = _content[key]
		if key == "children":
			# Children are stored separately, and added at the end
			for child in value:
				# Children exported and reimported as otherwise they show up as "<RecCounted#-...>"
				children_array.append(
					JSON.parse_string(child.as_json())
				)
		else:
			json_dict[key] = value
	json_dict["children"] = children_array
	return JSON.stringify(json_dict, "  ", false)