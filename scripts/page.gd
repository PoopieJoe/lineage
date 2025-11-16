class_name Page
extends Node2D

signal link_clicked(tag)
@export var isLeft:bool
@export var size:Vector2
@onready var footer: RichTextLabel = $Footer
@onready var content: Node2D = $MainContent

func _draw() -> void:
	if (isLeft):
		draw_rect(get_content_rect(),Color.BLUE,false)
	else:
		draw_rect(get_content_rect(),Color.RED,false)

func _ready() -> void:
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if isLeft else HORIZONTAL_ALIGNMENT_LEFT

func clear() -> void:
	for child in content.get_children():
		content.remove_child(child)

func loadContent(new_content: Node2D, pageNumber: int)->void:
	content.add_child(new_content)
	content.position = get_content_topleft()
	footer.text = "%d" % pageNumber

func _on_main_content_meta_clicked(meta: String) -> void:
	emit_signal("link_clicked",meta)

func get_content_topleft() -> Vector2:
	return -size/2
	
func get_content_rect() -> Rect2:
	return Rect2(-size/2, size)
