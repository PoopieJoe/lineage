class_name PageElement
extends Node2D

var _size: Vector2 = Vector2.ZERO
var size: Vector2:
	get:
		return get_size()
	set(value):
		set_size(value)

func draw_bounding_box(color: Color = Color.MAGENTA, width: int = 2) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), color, false, width)

func _draw() -> void:
	#draw_bounding_box()
	pass

func add_element(e: PageElement) -> void:
	add_child(e)
	e.position.y = size.y
	size.y += e.get_rect().size.y

func get_rect() -> Rect2:
	return Rect2(position, size)

func get_absolute_rect()-> Rect2:
	return Rect2(global_position, size)

func get_size() -> Vector2:
	return _size

func set_size(value: Vector2):
	_size = value