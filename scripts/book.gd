extends Node2D

@onready var leftPage: Page = $LeftPage
@onready var rightPage: Page = $RightPage
@onready var prevPage: Page
@onready var nextPage: Page
@onready var leftPageNr: int = 1
	
func _ready() -> void:
	var p1file := FileAccess.open("res://assets/text/Page1.txt",FileAccess.READ)
	leftPage.loadContent(p1file.get_as_text(), leftPageNr)
	p1file.close()
	
	var p2file := FileAccess.open("res://assets/text/Page2.txt",FileAccess.READ)
	rightPage.loadContent(p2file.get_as_text(), leftPageNr + 1)
	p2file.close()

func _on_left_page_link_clicked(tag: Variant) -> void:
	print("Clicked %s on left page" % tag)

func _on_right_page_link_clicked(tag: Variant) -> void:
	print("Clicked %s on right page" % tag)

func _on_left_page_button_button_up() -> void:
	if leftPageNr == 1:
		pass
	elif leftPageNr == 3:
		leftPageNr -= 2
		var p1file := FileAccess.open("res://assets/text/Page1.txt",FileAccess.READ)
		leftPage.loadContent(p1file.get_as_text(), leftPageNr)
		p1file.close()
		
		var p2file := FileAccess.open("res://assets/text/Page2.txt",FileAccess.READ)
		rightPage.loadContent(p2file.get_as_text(), leftPageNr + 1)
		p2file.close()

func _on_right_page_button_button_up() -> void:
	if leftPageNr == 1:
		leftPageNr += 2
		var p1file := FileAccess.open("res://assets/text/Page3.txt",FileAccess.READ)
		leftPage.loadContent(p1file.get_as_text(), leftPageNr)
		p1file.close()
		
		var p2file := FileAccess.open("res://assets/text/Page4.txt",FileAccess.READ)
		rightPage.loadContent(p2file.get_as_text(), leftPageNr + 1)
		p2file.close()
	elif leftPageNr == 3:
		pass
