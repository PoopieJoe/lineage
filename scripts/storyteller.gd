extends Node
class_name Storyteller

var _event_database: EventDatabase
var _world_state: WorldState
var _current_event: EventRootNode = null
var _past_events: Array[EventRootNode] = []
var _world_map: Map
@export var data_path: String = "res://data/"
@export var event_folder: String = "events/"
@export var map_folder: String = "maps/"
@export var initial_event_id: String = "test"
@export var initial_location_id: String = "tutorial_temple"
signal event_resolved(new_event: EventRootNode)

func _init() -> void:
    _world_state = WorldState.new()
    _event_database = EventDatabase.new()
    _event_database.load_events(data_path + event_folder)
    var map_parser = MapParser.new()
    var maps = map_parser.load_from_dir(data_path + map_folder)
    Logger.info("Loaded %d maps from %s" % [maps.size(), data_path + map_folder])
    _world_map = maps["world"]
    var mapviz = MapVisualizer.new()
    # mapviz.load_map(_world_map)
    mapviz.to_svg_file(data_path + map_folder + "world.svg")

func _get_current_location_name() -> String:
    return _world_map.vertex_name(_world_state.get_state(WorldState.LOCATION_KEY))

func _ready() -> void:
    _current_event = _event_database.get_event(initial_event_id).build(_world_state)
    _world_state.set_state(WorldState.LOCATION_KEY, initial_location_id)
    print("current location: " + _get_current_location_name())

func get_world_state() -> WorldState:
    return _world_state

func get_current_event() -> EventRootNode:
    return _current_event

func resolve_event(choice: String) -> void:
    var choices = _current_event.get_choices()
    var next_event_id = null
    for c: ChoiceNode in choices:
        if c.get_text() == choice:
            next_event_id = c.get_choice()
            break

    if next_event_id == null:
        Logger.error("Choice '%s' not found" % choice)
    else:
        Logger.log("Choice '%s' selected" % choice)
        _past_events.append(_current_event)
        _current_event = _event_database.get_event(next_event_id).build(_world_state)
        event_resolved.emit(_current_event)