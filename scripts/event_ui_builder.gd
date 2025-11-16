class_name EventUIBuilder

static func make_element(type: String, data: Dictionary):
	var element: PageElement
	match (type):
		TextNode.type:
			element = Text2D.new()
			element.text = data[TextNode.text_key]
			element.width = 600.0
		ImageNode.type:
			element = Image2D.new()
			element.load_image(data[ImageNode.resource_path])
		ChoiceNode.type:
			element = TextButton2D.new()
			element.set_text(data[TextNode.text_key])
			element.width = 600.0
		_:
			Logger.error("Node of type <%s> has no contructor" % type)
	return element

static func make_UIElements(content: EventNode) -> Array[PageElement]:
	var page_content: Array[PageElement] = []
	if content.has("children"):
		for node in content.get_content("children"):
			var element = EventUIBuilder.make_element(node.get_type(), node.get_all_content())
			page_content.append(element)
	return page_content
