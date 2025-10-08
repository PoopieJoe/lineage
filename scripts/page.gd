class_name Page
extends Node2D

signal link_clicked(tag)
@export var isLeft:bool
@onready var mainContent: RichTextLabel = $MainContent
@onready var footer: RichTextLabel = $Footer

func _ready() -> void:
	mainContent.bbcode_enabled = true
	mainContent.meta_underlined = true
	footer.horizontal_alignment =  HORIZONTAL_ALIGNMENT_RIGHT if isLeft else HORIZONTAL_ALIGNMENT_LEFT

func loadContent(content: String, pageNumber: int)->void:
	mainContent.text = ContentParser.parse(content)
	footer.text = "%d" % pageNumber

func _on_main_content_meta_clicked(meta: String) -> void:
	emit_signal("link_clicked",meta)
