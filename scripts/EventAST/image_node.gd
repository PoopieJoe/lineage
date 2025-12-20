extends EventNode
class_name ImageNode

func _init(path: String):
	super ("image")
	set_content("resource_path", path)

func get_resource() -> String:
	return get_content("resource_path")