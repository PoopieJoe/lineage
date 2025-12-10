extends Node
class_name Map

var id: String
var vertices = {} 
var edges = {}
const VERTEX_NAME_KEY: String = "name"

func _init(_id : String, _vertices = {}, _edges = {}):
    id = _id
    vertices = _vertices
    edges = _edges

# Basic access
func has(_id: String) -> bool:
    return vertices.has(_id)

func get_vertex(_id: String) -> Dictionary:
    return vertices.get(_id, {})

func vertex_name(_id: String) -> String:
    var n = get_vertex(_id)
    return n.get(VERTEX_NAME_KEY, "")

func neighbors(_id: String) -> Array:
    return edges.get(_id, []).duplicate()

# Edge helpers
func has_edge(a: String, b: String) -> bool:
    if not edges.has(a):
        return false
    return edges[a].has(b)

# BFS shortest path (returns Array of ids or empty if none)
func find_path(start: String, goal: String) -> Array:
    if start == goal:
        return [start]
    if not has_node(start) or not has_node(goal):
        return []
    var q = []
    q.push_back(start)
    var came_from = {}
    came_from[start] = null
    while q.size() > 0:
        var cur = q.pop_front()
        for neigh in neighbors(cur):
            if not came_from.has(neigh):
                came_from[neigh] = cur
                if neigh == goal:
                    var path = []
                    var p = goal
                    while p != null:
                        path.insert(0, p)
                        p = came_from[p]
                    return path
                q.push_back(neigh)
    return []

# Connected components (returns Array of Arrays of ids)
func connected_components() -> Array:
    var seen = {}
    var comps = []
    for _id in vertices.keys():
        if seen.has(_id):
            continue
        var comp = []
        var q = [_id]
        seen[_id] = true
        while q.size() > 0:
            var cur = q.pop_front()
            comp.append(cur)
            for n in neighbors(cur):
                if not seen.has(n):
                    seen[n] = true
                    q.push_back(n)
        comps.append(comp)
    return comps

func _to_string() -> String:
    return "Map(id=%s, vertices=%s, edges=%s)" % [id, str(vertices), str(edges)]