extends Node
class_name Storyteller

var _event_database: EventDatabase
var _state: WorldState
var _current_event: EventBuilder = null
var _past_events: Array[EventRootNode] = []
var _world_map: Map
var _mapviz: MapVisualizer = MapVisualizer.new()
@export var data_path: String = "res://data/"
@export var event_folder: String = "events/"
@export var map_folder: String = "maps/"
@export var initial_event_id: String = "tutorial_start"
@export var initial_location_id: String = "tutorial_temple"
signal event_resolved(new_event: EventRootNode)

func _init() -> void:
    _event_database = EventDatabase.new()
    _event_database.load_events(data_path + event_folder)
    var map_parser = MapParser.new()
    var maps = map_parser.load_from_dir(data_path + map_folder)
    Logger.info("Loaded %d maps from %s" % [maps.size(), data_path + map_folder])
    _world_map = maps["world"]
    _mapviz = MapVisualizer.new()
    _mapviz.load_map(_world_map, data_path + map_folder + "world.svg", true)

    _state = WorldState.new()
    _state.write(WorldState.LOCATION_ID_KEY, initial_location_id)
    _state.write(WorldState.LOCATION_NAME_KEY, _world_map.vertex_name(initial_location_id))
    _state.write(WorldState.DATE_KEY, "DD MM YYYY")
    _state.write(WorldState.TIME_KEY, "HH:MM")

func get_location() -> String:
    return _world_map.vertex_name(_state.read(WorldState.LOCATION_ID_KEY))

func _ready() -> void:
    _current_event = _event_database.get_event(initial_event_id) \
        .add_header("%s\n%s\n%s\n " % [
			_state.read(WorldState.LOCATION_NAME_KEY), 
			_state.read(WorldState.DATE_KEY), 
			_state.read(WorldState.TIME_KEY)])
    _mapviz.highlight(_state.read(WorldState.LOCATION_ID_KEY), Color.RED)
    print("current location: " + get_location())

func get_world_state() -> WorldState:
    return _state

func get_current_event() -> EventBuilder:
    return _current_event

func click(node: EventNode) -> void:
    if node is ChoiceNode:
        _state.write(node.get_choice(), true)
    else:
        Logger.warning("Node %s has no associated click behavior" % node.get_type())

func resolve_event(choice: String) -> void:
    var next_event_id = null
    # Determine next event

    if next_event_id == null:
        Logger.error("Choice '%s' not found" % choice)
    else:
        Logger.log("Choice '%s' selected" % choice)
        _past_events.append(_current_event)
        _current_event = _event_database.get_event(next_event_id) \
            .add_header("%s\n%s\n%s\n " % [
                _state.read(WorldState.LOCATION_NAME_KEY), 
                _state.read(WorldState.DATE_KEY), 
                _state.read(WorldState.TIME_KEY)])
        event_resolved.emit(_current_event)