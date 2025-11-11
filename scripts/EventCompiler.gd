class_name EventCompiler

static func make_UIElements( content: EventNode ) -> Array[PageElement]:
	var page_content: Array[PageElement] = []
	for node in content.children:
		var element : PageElement
		match (node.get_type()):
			TextNode.type:
				element = Text2D.new()
				element.text = node.content
				element.width = 600.0
			ImageNode.type:
				element = Image2D.new()
				element.load_image(node.image_path)
			ChoiceNode.type:
				element = Text2D.new()
				element.text = node.text
				element.width = 600.0
			_:
				push_error("Node of undefined type <%s>" % node.get_type())
		page_content.append(element)
	return page_content
