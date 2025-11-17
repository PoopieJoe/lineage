class_name EventUIBuilder

static func make_element(type: String, data: Dictionary, settings: Dictionary, resolve_event: Callable) -> PageElement:
    var element: PageElement
    match (type):
        TextNode.type:
            var font: FontFile = load(settings["default_font"]["path"]) as FontFile
            element = Text2D.new(data[TextNode.text_key], font)
            element.width = 600.0
        ImageNode.type:
            element = Image2D.new()
            element.load_image(data[ImageNode.resource_path])
        ChoiceNode.type:
            var font: FontFile = load(settings["default_font"]["path"]) as FontFile
            element = TextButton2D.new(data[ChoiceNode.text_key], font)
            element.set_on_click(resolve_event)
            element.width = 600.0
        _:
            Logger.error("Node of type <%s> has no contructor" % type)
    return element

static func make_UIElements(content: EventRootNode, resolve_event: Callable, settings) -> Array[PageElement]:
    var page_content: Array[PageElement] = []
    if content.has_children():
        for node in content.get_children():
            var element = EventUIBuilder.make_element(
                node.get_type(),
                node.get_all_content(),
                settings,
                resolve_event)
            page_content.append(element)
    return page_content
