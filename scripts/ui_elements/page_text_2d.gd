class_name Text2D
extends PageElement

var alignment:HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
var text_color:Color = Color.BLACK

func _draw():
	draw_bounding_box()
	if font and text != "":
		draw_multiline_string( font,  Vector2(0,font.get_height(font_size)), 
			text, alignment, width, font_size, -1, text_color )

var font = ThemeDB.fallback_font:
	get:
		return font
	set(value):
		font = value
		size = font.get_multiline_string_size(text,alignment,width,font_size)
	
var font_size = 20:
	get:
		return font_size
	set(value):
		font_size = value
		size = font.get_multiline_string_size(text,alignment,width,font_size)
		
var width = -1:
	get:
		return width
	set(value):
		width = value
		size = font.get_multiline_string_size(text,alignment,width,font_size)

var text: String = "":
	get:
		return text
	set(value):
		text = value
		size = font.get_multiline_string_size(text,alignment,width,font_size)

func get_rect() -> Rect2:
	return Rect2(Vector2.ZERO,size)
