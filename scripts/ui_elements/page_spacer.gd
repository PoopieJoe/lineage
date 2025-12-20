class_name Spacer2D
extends PageElement

var _font: Font
var font_size = 20
var height: float = 1.0
const width = 600.0

func _draw() -> void:
	# draw_bounding_box()
	pass

func _init(h: float, font: Font = ThemeDB.fallback_font) -> void:
	height = h
	_font = font
	size = Vector2(width, _font.get_height(font_size) * height)
	