class_name EventNode
extends RefCounted

var _content: Dictionary
var _type: String

func _init(type: String = "root"):
	_type = type
	_content = Dictionary()

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
