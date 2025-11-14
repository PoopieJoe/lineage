class_name Image2D
extends PageElement

var sprite: Sprite2D

func _draw() -> void:
	draw_bounding_box()

func _init() -> void:
	sprite = Sprite2D.new()
	sprite.centered = false
	add_child(sprite)

func load_image(path: String) -> void:
	var image = Image.load_from_file(path)
	sprite.texture = ImageTexture.create_from_image(image)
		
func get_rect() -> Rect2:
	return sprite.get_rect()
