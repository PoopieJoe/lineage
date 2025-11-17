class_name Text2D
extends PageElement

var alignment:HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
var text_color:Color = Color.BLACK

var _font: Font
var font_size = 20
var width = -1
var _text: String = ""

func _init(text: String = "", font: Font = ThemeDB.fallback_font) -> void:
	_text = text
	_font = font

func _draw() -> void:
	# draw_bounding_box()
	if _font and _text != "":
		draw_multiline_string( _font,  Vector2(0,_font.get_height(font_size)), 
			_text, alignment, width, font_size, -1, text_color )

func set_text(value: String) -> void:
	_text = value
	queue_redraw()

func set_font(value: Font) -> void:
	_font = value
	queue_redraw()

func get_size():
	return _font.get_multiline_string_size(_text,alignment,width,font_size)