extends Object
class_name MapVisualizer

var _map = null

func _init() -> void:
    pass

func load_map(map: Map) -> void:
    _map = map

func to_dot_str() -> String:
    if _map == null:
        Logger.error("No map loaded")
        return ""
    var dot_str = "graph \"%s\" {\n" % _map.id
    for vertex_id in _map.vertices.keys():
        var vertex = _map.get_vertex(vertex_id)
        var vertex_name = vertex.get("name", vertex_id)
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

func to_dot_file(file_path: String) -> void:
    if _map == null:
        Logger.error("No map loaded")
        return
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file == null:
        Logger.error("Can't open file '%s' for writing due to <%i>" % [file_path, FileAccess.get_open_error()])
        return
    file.store_string(to_dot_str())
    file.close()

func to_svg_file(file_path: String) -> void:
    if _map == null:
        Logger.error("No map loaded")
        return
    file_path = ProjectSettings.globalize_path(file_path)
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
