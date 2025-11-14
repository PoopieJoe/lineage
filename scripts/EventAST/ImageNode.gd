extends EventNode
class_name ImageNode

const type = "image"
const resource_path = "resource_path"

func _init(path: String):
	super (type)
	set_content(resource_path, path)

func get_resource() -> String:
	return get_content(resource_path)