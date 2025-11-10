class_name Text2D
extends PageElement

var text: String = ""
var font = ThemeDB.fallback_font

func _draw():
	if font and text != "":
		draw_string(font, Vector2.ZERO, text)
