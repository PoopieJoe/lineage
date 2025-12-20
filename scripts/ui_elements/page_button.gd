class_name ChoiceButton2D
extends PageElement

# Button color states
const text_color: Color = Color.BLACK
const hover_color: Color = Color.RED
const pressed_color: Color = Color.GREEN

var alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT # Alignment of the button text
var _current_color: Color = Color.BLACK

var _font: Font
var font_size = 20
const width = 600
var _text: String
const _prefix: String = " > "
var _node: ChoiceNode

var _area: Area2D # Area2D for detecting mouse events
var _collider: CollisionShape2D # Collision shape for the button
var _shape: RectangleShape2D # Shape of the button
var _on_click: Callable # Callable to execute on button click

func _init(node: ChoiceNode, text: String, font: Font = ThemeDB.fallback_font) -> void:
	_text = text
	_font = font
	_node = node

	# Initialize Area2D and CollisionShape2D for mouse interaction
	_area = Area2D.new()
	_collider = CollisionShape2D.new()
	_shape = RectangleShape2D.new()
	_area.add_child(_collider)
	add_child(_area)
	
	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	_area.input_event.connect(_on_input_event)
	_update_button_area()

func _on_mouse_entered() -> void:
	_current_color = Color.RED
	queue_redraw()

func _on_mouse_exited() -> void:
	_current_color = Color.BLACK
	queue_redraw()

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if not event.pressed:
			_on_click.call(self)
			_current_color = Color.BLACK
		else:
			_current_color = Color.GREEN
		queue_redraw()

func _update_button_area() -> void:
	_shape.size = get_size()
	_collider.shape = _shape
	_collider.position = get_size() / 2

func get_evt_node() -> ChoiceNode:
	return _node

func set_text(value: String) -> void:
	# Set the button text and update size and collider
	_text = _prefix + value
	_update_button_area()
	queue_redraw()

func set_font(value: Font) -> void:
	_font = value
	_update_button_area()
	queue_redraw()

func set_on_click(callable: Callable) -> void:
	_on_click = callable

func _draw():
	# draw_bounding_box()
	if _font and _text != "":
		draw_multiline_string(_font, Vector2(0, _font.get_height(font_size)), _prefix + _text, alignment, width, font_size, -1, _current_color)

func get_size():
	return _font.get_multiline_string_size(_prefix + _text, alignment, width, font_size)

func set_size(_value: Vector2):
	Logger.error("set_size() should not be called on ChoiceButton2D")