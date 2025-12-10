extends Node
class_name MapParser

const MAP_EXTENSION: String = ".map"
const vertex_key: String = "vertex"
const edge_key: String = "edge"
var _vertex_re: RegEx
var _edge_re: RegEx

func _init() -> void:
    # Build RegEx to filter for: node node_id "node_name"
    _vertex_re = RegEx.new()
    var reg_str = r"%s\s+(\S+)\s+\"([^\"]+)\"" % vertex_key
    _vertex_re.compile(reg_str)
    
    # Build RegEx to filter for: edge node_id1 node_id2
    _edge_re = RegEx.new()
    reg_str = r"%s\s+(\S+)\s+(\S+)" % edge_key
    _edge_re.compile(reg_str)

func load_from_dir(path: String) -> Dictionary:
    var dir = DirAccess.open(path)
    var events = {}
    if dir == null:
        Logger.error("Can't open folder '%s' due to <%i>" % [path, DirAccess.get_open_error()])
        return events
    dir.list_dir_begin()
    var fname = dir.get_next()
    while fname != "":
        if not dir.current_is_dir() and fname.to_lower().ends_with(MAP_EXTENSION):
            var filepath = dir.get_current_dir() + "/" + fname
            if FileAccess.file_exists(filepath):
                var data = _parse_file(filepath)
                if data:
                    var id = fname.split(MAP_EXTENSION)[0]
                    events[id] = _build_map_from_data(id, data)
        fname = dir.get_next()
    dir.list_dir_end()
    return events

func _parse_file(path: String) -> Dictionary:
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        Logger.error("Can't open file '%s' due to <%i>" % [path, FileAccess.get_open_error()])
        return {}
    var raw = file.get_as_text()
    file.close()
    var vertex_matches = _vertex_re.search_all(raw)
    var vertexes = {}
    for v in vertex_matches:
        var v_id = v.get_string(1)
        var v_name = v.get_string(2)
        vertexes[v_id] = {Map.VERTEX_NAME_KEY: v_name}
    var edges = {}
    var edge_matches = _edge_re.search_all(raw)
    for e in edge_matches:
        var a = e.get_string(1)
        var b = e.get_string(2)
        edges[a] = edges.get(a, []) + [b]
        edges[b] = edges.get(b, []) + [a]
    return {vertex_key: vertexes, edge_key: edges}

func _build_map_from_data(id: String, data: Dictionary) -> Map:
    return Map.new(id, data[vertex_key], data[edge_key])