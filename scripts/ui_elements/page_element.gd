class_name PageElement
extends Node2D

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
			var c_right = c_top + c_rect.size.x
			if c_top < top: top = c_top
			if c_left < left: left = c_left
			if c_bottom > bottom: bottom = c_bottom
			if c_right > right: right = c_right
	return Rect2(left,top,right-left,bottom-top)
