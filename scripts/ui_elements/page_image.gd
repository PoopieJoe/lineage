class_name Image2D
extends PageElement

var sprite: Sprite2D

func _init() -> void:
	sprite = Sprite2D.new()
	add_child(sprite)

func load_image(path: String) -> void:
	var image = Image.load_from_file(path)
	sprite.texture = ImageTexture.create_from_image(image)
