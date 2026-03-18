class_name ChoiceButton2D
extends PageElement

var _resource_path = "res://assets/"

# Button colors
const text_color: Color = Color.BLACK
const hover_color: Color = Color.RED
const disabled_color: Color = Color.DARK_GRAY

# icons
var _icon: Texture2D = null
var _icon_size: Vector2 = Vector2.ZERO
var _icon_offset: int = 40

var alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT # Alignment of the button text
var _current_color: Color = Color.BLACK

var _font: Font
var font_size = 20
const width = 600
var _text: String

var _area: Area2D # Area2D for detecting mouse events
var _collider: CollisionShape2D # Collision shape for the button
var _shape: RectangleShape2D # Shape of the button
var _on_click: Callable # Callable to execute on button click
var enabled: bool = true
var hovered: bool = false

func _init(text: String, font: Font = ThemeDB.fallback_font) -> void:
    _text = text
    _font = font

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
    if enabled == false:
        return
    hovered = true
    queue_redraw()

func _on_mouse_exited() -> void:
    if enabled == false:
        return
    hovered = false
    queue_redraw()

func _on_input_event(_viewport, event, _shape_idx) -> void:
    if enabled == false:
        return
    if event is InputEventMouseButton:
        if not event.pressed:
            _on_click.call(self)
            queue_redraw()

func _update_button_area() -> void:
    var text_size = get_size()
    var total_height = max(text_size.y, _icon_size.y)
    _shape.size = Vector2(text_size.x + _icon_offset, total_height)
    _collider.shape = _shape
    _collider.position = Vector2((_shape.size.x / 2) - _icon_offset, total_height / 2)

func set_text(value: String) -> void:
    # Set the button text and update size and collider
    _text = value
    _update_button_area()
    queue_redraw()
    
func set_icon(svg_path: String, icon_size: Vector2 = Vector2(30, 30)) -> void:
    _icon = load(_resource_path + svg_path)
    _icon_size = icon_size
    queue_redraw()

func set_font(value: Font) -> void:
    _font = value
    _update_button_area()
    queue_redraw()

func set_on_click(callable: Callable) -> void:
    _on_click = callable

func disable() -> void:
    enabled = false
    queue_redraw()

func _draw():
    # draw_bounding_box()
    if enabled:
        # TODO conditional rendering for hovered button
        if hovered:
            if _icon:
                var text_size = get_size()
                var icon_y = (text_size.y - _icon_size.y) / 2
                var icon_rect = Rect2(
                    Vector2(-_icon_offset, icon_y),
                    _icon_size
                )
                draw_texture_rect(_icon, icon_rect, false)
    else:
        _current_color = disabled_color
    if _font and _text != "":
        draw_multiline_string(_font, Vector2(0, _font.get_height(font_size)), _text, alignment, width, font_size, -1, _current_color)

func get_size():
    return _font.get_multiline_string_size(_text, alignment, width, font_size)

func set_size(_value: Vector2):
    Logger.error("set_size() should not be called on ChoiceButton2D")