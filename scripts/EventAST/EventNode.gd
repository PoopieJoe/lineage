class_name EventNode
extends RefCounted

var children: Array[EventNode]
var _type: String

func _init(type: String = "root"):
	_type = type
	children = []

func add_node(node: EventNode) -> void:
	children.append(node)

func get_type():
	return _type
