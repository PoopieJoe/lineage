class_name EventNode
extends RefCounted

var _content: Dictionary
var _type: String
const children_key = "children"

func _init(type: String):
	_type = type
	_content = Dictionary()
	set_content(children_key, [])

func has_children() -> bool:
	var children: Array = get_content(children_key)
	return children.size() > 0

func get_children() -> Array:
	return get_content(children_key) as Array[EventNode]

func add_child(child: EventNode):
	var children = get_content(children_key) as Array[EventNode]
	children.append(child)

func add_children(new_children: Array[EventNode]):
	var children: Array = get_content(children_key)
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