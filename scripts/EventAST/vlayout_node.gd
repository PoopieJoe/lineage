class_name VLayoutNode
extends EventNode

const type = "vlayout"
const children_key = "children"

func _init(children: Array[EventNode] = []):
	super (type)
	set_content(children_key, children)

func get_children() -> Array[EventNode]:
	return get_content(children_key)

func add_child(child: EventNode):
	var children: Array = get_content(children_key)
	children.append(child)

func add_children(new_children: Array[EventNode]):
	var children: Array = get_content(children_key)
	children.append_array(new_children)
