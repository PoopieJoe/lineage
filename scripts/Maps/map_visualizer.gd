extends Object
class_name MapVisualizer

var _map = null
var _dot_repr: String = ""
var _highlighted_nodes: Dictionary = {}
var _live_update: bool = false
var _needs_redraw_sem: Semaphore
var _dot_repr_lock: Mutex
var _update_thread: Thread
var _map_path: String = ""

func _init() -> void:
    pass    

func load_map(map: Map, output_file_svg: String = "", live_update: bool = false) -> void:
    _map = map
    _live_update = live_update
    if _live_update:
        if output_file_svg == "":
            Logger.error("Live update requires an output SVG file path")
            _live_update = false
        else:
            _update_thread = Thread.new()
            _needs_redraw_sem = Semaphore.new()
            _dot_repr_lock = Mutex.new()
            _update_thread.start(_update_thread_func)
    _map_path = ProjectSettings.globalize_path(output_file_svg)

func _update_thread_func() -> void:
    while true:
        if _needs_redraw_sem.try_wait():
            OS.delay_msec(1000)
            to_svg_file(_map_path)

func _build_dot_str():
    if _map == null:
        Logger.error("No map loaded")
        return ""
    var dot_str = "graph \"%s\" {\n" % _map.id
    for vertex_id in _map.vertices.keys():
        var vertex = _map.get_vertex(vertex_id)
        var vertex_name = vertex.get("name", vertex_id)
        # add color attribute if this node is highlighted
        if _highlighted_nodes.has(vertex_id):
            var col = _highlighted_nodes[vertex_id]
            # set penwidth to make the outline visible
            dot_str += '    "%s" [label="%s", color="%s", penwidth=2];\n' % [vertex_id, vertex_name, col]
        else:
            dot_str += '    "%s" [label="%s"];\n' % [vertex_id, vertex_name]

    # Emit each undirected edge once by using a canonical key (min|max)
    var emitted = {}
    for from_id in _map.edges.keys():
        for to_id in _map.edges[from_id]:
            var key = "%s|%s" % [from_id, to_id] if from_id < to_id else "%s|%s" % [to_id, from_id]
            if emitted.has(key):
                continue
            emitted[key] = true
            dot_str += '    "%s" -- "%s";\n' % [from_id, to_id]

    dot_str += "}\n"
    return dot_str

func _set_dot_repr(new_dot: String) -> void:
    if _live_update:
        _dot_repr_lock.lock()
        _dot_repr = new_dot
        _dot_repr_lock.unlock()
    else:
        _dot_repr = new_dot

func _get_dot_repr() -> String:
    var repr: String
    if _live_update:
        _dot_repr_lock.lock()
        repr = _dot_repr
        _dot_repr_lock.unlock()
    else:
        repr = _dot_repr
    return repr

func _regenerate() -> void:
    var new = _build_dot_str()
    if _live_update:
        if new != _get_dot_repr():
            _needs_redraw_sem.post()
    _set_dot_repr(new)

func to_dot_file(file_path: String) -> void:
    if _map == null:
        Logger.error("No map loaded")
        return
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file == null:
        Logger.error("Can't open file '%s' for writing due to <%i>" % [file_path, FileAccess.get_open_error()])
        return
    file.store_string(_get_dot_repr())
    file.close()

func to_svg_file(file_path: String) -> void:
    if _map == null:
        Logger.error("No map loaded")
        return
    var tmp_path = file_path.get_base_dir() + "/tmp_" + file_path.get_basename().get_file()
    to_dot_file(tmp_path)
    var output = []
    var result = OS.execute("sfdp", ["-Tsvg", "-o", file_path, tmp_path], output)
    if result != 0:
        Logger.error("Failed to generate SVG from DOT file '%s'" % tmp_path)
    print('\n'.join(output))
    var folder = DirAccess.open(file_path.get_base_dir())
    if folder != null:
        folder.remove(tmp_path.get_file())

func highlight(node_id: String, color: Color) -> void:
    _highlighted_nodes[node_id] = '#' + color.to_html(false)
    _regenerate()

func unhighlight(node_id: String) -> void:
    if _highlighted_nodes.has(node_id):
        _highlighted_nodes.erase(node_id)
        _regenerate()
