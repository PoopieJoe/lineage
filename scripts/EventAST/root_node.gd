class_name EventRootNode
extends EventNode

func _init(children: Array[EventNode] = []):
	super ("root", null)
	add_children(children)

func add_tag(tag: String):
	if has("tags") == false:
		set_content("tags", [])
	var tags = get_content("tags")
	tags.append(tag)
	set_content("tags", tags)

func get_tags() -> Array[String]:
	return get_content("tags")

func set_identifier(id: String):
	set_content("identifier", id)

func get_identifier() -> String:
	return get_content("identifier")

func has_identifier() -> bool:
	return has("identifier")
