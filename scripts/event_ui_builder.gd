class_name EventUIBuilder

static func make_element(type: String, data: Dictionary, font: FontFile, resolve_event: Callable) -> PageElement:
    var element: PageElement
    match (type):
        TextNode.type:
            element = Text2D.new(data[TextNode.text_key], font)
        ImageNode.type:
            element = Image2D.new()
            element.load_image(data[ImageNode.resource_path])
        ChoiceNode.type:
            element = TextButton2D.new(data[ChoiceNode.text_key], font)
            element.set_on_click(resolve_event)
        _:
            Logger.error("Node of type <%s> has no contructor" % type)
    return element

static func make_UIElements(content: EventRootNode, resolve_event: Callable, settings) -> Array[PageElement]:
    var page_content: Array[PageElement] = []
    var font: FontFile = load(settings["default_font"]["path"]) as FontFile
    if content.has_children():
        for node in content.get_children():
            var element = EventUIBuilder.make_element(
                node.get_type(),
                node.get_all_content(),
                font,
                resolve_event)
            page_content.append(element)
    return page_content
