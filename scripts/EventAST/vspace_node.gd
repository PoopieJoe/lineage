extends EventNode
class_name VSpaceNode

func _init(size: int):
	super ("vspace")
	set_size( size )

func get_size() -> int:
	return get_content("size")

func set_size(size: int):
	set_content("size", size)