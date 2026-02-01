extends EventNode
class_name ImageNode

func _init(parent: EventNode, path: String):
	super("image", parent)
	set_content("resource_path", path)

func get_resource() -> String:
	return get_content("resource_path")