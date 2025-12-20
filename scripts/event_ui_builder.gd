class_name EventUIBuilder

static func make_UIElements(content: EventNode, on_click: Callable, settings) -> Array[PageElement]:
    var page_content: Array[PageElement] = []
    var font: FontFile = load(settings["default_font"]["path"]) as FontFile
    if content.has_children():
        for node in content.get_children():
            var data = node.get_all_content()
            var type = node.get_type()
            match (type):
                "text":
                    page_content.append(Text2D.new(data["text"], font))
                "image":
                    var element = Image2D.new()
                    element.load_image(data["resource_path"])
                    page_content.append(element)
                "choice":
                    var element = ChoiceButton2D.new(node, data["text"], font)
                    element.set_on_click(on_click)
                    page_content.append(element)
                "vspace":
                    page_content.append(Spacer2D.new(data["size"], font))
                "section":
                    page_content.append(Text2D.new("---SECTION BREAK---", font))
                    for e in make_UIElements(node, on_click, settings):
                        page_content.append(e)
                "branch":
                    for e in make_UIElements(node, on_click, settings):
                        page_content.append(e)
                _:
                    Logger.warning("Node of type \"%s\" has no element" % type)
            
    return page_content
