extends Node2D

@onready var leftPage: Page = $LeftPage
@onready var rightPage: Page = $RightPage
@onready var leftPageNr: int = 1
@onready var storyteller = $Storyteller

var currentpage: int = 0
var _section_ui: Array[PageElement]
var pages: Array[PageElement]
var settings: Dictionary
var interpreter: EVTInterpreter
    
func next_page() -> void:
    if currentpage < pages.size() - 2:
        load_page(currentpage + 2)
    
func prev_page() -> void:
    if currentpage > 0:
        load_page(currentpage - 2)
    
func reload_page() -> void:
    load_page(currentpage)

func load_page(page_idx: int) -> void:
    currentpage = page_idx
    leftPage.clear()
    rightPage.clear()
    if page_idx < pages.size():
        leftPage.loadContent(pages[page_idx], page_idx + 1)
    if page_idx + 1 < pages.size():
        rightPage.loadContent(pages[page_idx + 1], page_idx + 2)
    
func extend_page(page: PageElement, elements: Array[PageElement]) -> Array:
    var page_full = false
    var consumed_elements: int = 0
    while not page_full:
        var e: PageElement
        if consumed_elements < elements.size():
            e = elements[consumed_elements]
        else:
            break
        consumed_elements += 1
        var page_size = page.get_rect().size
        var c_size = e.get_rect().size
        assert(c_size.y < leftPage.size.y)
        
        if page_size.y + c_size.y > leftPage.size.y:
            page_full = true
            consumed_elements -= 1
        else:
            page.add_child(e)
            e.position = Vector2(0, page_size.y)
            page.set_size(Vector2(leftPage.size.x, page_size.y + c_size.y))
    return [page, consumed_elements]

func make_page(elements: Array[PageElement]) -> Array:
    var new_page = PageElement.new()
    return extend_page(new_page, elements)

func add_elements(elements: Array[PageElement]) -> void:
    var consumed_elements = 0
    if pages.size() == 0:
        var ret = make_page(elements)
        var first_page = ret[0]
        pages.append(first_page)
        consumed_elements += ret[1]
    else:
        var ret = extend_page(pages[-1], elements)
        consumed_elements += ret[1]
        
    while consumed_elements < elements.size():
        var ret = make_page(elements.slice(consumed_elements))
        var new_page = ret[0]
        consumed_elements += ret[1]
        pages.append(new_page)
    reload_page()
  
func on_click(element: PageElement) -> void:
    pass

func _on_new_element(type, value) -> void:
    match type:
        "text":
            var el = Text2D.new(value)
            add_elements([el])
        "vspace":
            var el = Spacer2D.new(value)
            add_elements([el])
        "choice":
            var el = ChoiceButton2D.new(value["label"])
            var onclick = func (_button: ChoiceButton2D) -> void:
                interpreter.element_interaction.emit(type, value["label"])
            el.set_on_click(onclick)
            add_elements([el])

        _:
            print("Unknown element type: %s" % type)
            pass


func _ready() -> void:
    if $DebugLog/VBoxContainer/Feed:
        Logger.set_output($DebugLog/VBoxContainer/Feed)

    settings = YAML.parse_file("res://settings.yaml")

    var loaded_events = []
    var dirstr = "res://data/events/"
    var dir = DirAccess.open(dirstr)
    for fstr in dir.get_files():
        if fstr.ends_with(".evt"):
            var file = FileAccess.open(dirstr + fstr, FileAccess.READ)
            var file_content = file.get_as_text()
            
            if file_content != "":
                var tokenizer = EvtLexer.new(file_content)
                var tokens = tokenizer.tokenize()
                var parser = EVTParser.new(tokens)
                var ast = parser.parse()
                loaded_events.append(ast)

    interpreter = EVTInterpreter.new(loaded_events[0])
    interpreter.new_element.connect(_on_new_element)
    var metadata = interpreter.meta()
    print(metadata)
    interpreter.run()
    load_page(0)

func _on_left_page_button_button_up() -> void:
    prev_page()

func _on_right_page_button_button_up() -> void:
    next_page()
