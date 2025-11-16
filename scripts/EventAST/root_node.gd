class_name EventRootNode
extends EventNode

const type = "root"
const tags_key = "tags"
const id_key = "identifier"

func _init(children: Array[EventNode] = []):
	super (type)
	add_children(children)

func add_tag(tag: String):
	var tags = get_content(tags_key)
	tags.append(tag)
	set_content(tags_key, tags)

func get_tags() -> Array[String]:
	return get_content(tags_key)

func set_identifier(id: String):
	set_content(id_key, id)

func get_identifier() -> String:
	return get_content(id_key)

func has_identifier() -> bool:
	return has(id_key)

func get_choices() -> Array[ChoiceNode]:
	var choices: Array[ChoiceNode] = []
	for child in get_children():
		if child.get_type() == ChoiceNode.type:
			choices.append(child)
	return choices