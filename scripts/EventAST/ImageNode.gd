extends EventNode
class_name ImageNode

var image_path: String
const type = "image"

func _init(_path: String):
	super(type)
	image_path = _path
