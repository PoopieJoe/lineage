class_name PageElement
extends Node2D

var max_size: Vector2 = Vector2(600,750)
var size: Vector2 = Vector2.ZERO

func draw_bounding_box(color:Color = Color.MAGENTA,width:int = 2) -> void:
	draw_rect(get_rect(),color,false,width)

func _draw() -> void:
	draw_bounding_box()

func add_element(e:PageElement) -> bool:
	var c_size = e.get_rect().size
	if size.y + c_size.y > max_size.y:
		return false
		
	add_child(e)
	e.position.y = size.y
	size.y += c_size.y
	return true

func get_rect() -> Rect2:
	var top = 0.0
	var left = 0.0
	var bottom = 0.0
	var right = 0.0
	for child in get_children():
		if child is PageElement:
			var c_rect = child.get_rect()
			var c_top = c_rect.position.y
			var c_left = c_rect.position.x
			var c_bottom = c_top + c_rect.size.y
			var c_right = c_rect.size.x
			if c_top < top: top = c_top
			if c_left < left: left = c_left
			if c_bottom > bottom: bottom = c_bottom
			if c_right > right: right = c_right
	return Rect2(left,top,right-left,bottom-top)
