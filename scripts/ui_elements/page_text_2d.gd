class_name Text2D
extends PageElement

var alignment:HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
var text_color:Color = Color.BLACK

var font = ThemeDB.fallback_font
var font_size = 20
var width = -1
var text: String = ""

func _draw():
	# draw_bounding_box()
	if font and text != "":
		draw_multiline_string( font,  Vector2(0,font.get_height(font_size)), 
			text, alignment, width, font_size, -1, text_color )

func get_size():
	return font.get_multiline_string_size(text,alignment,width,font_size)