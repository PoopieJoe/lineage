extends Node
class_name Storyteller

var _state: WorldState
var _world_map: Map
var _mapviz: MapVisualizer = MapVisualizer.new()
@export var data_path: String = "res://data/"
@export var event_folder: String = "events/"
@export var map_folder: String = "maps/"
@export var initial_event_id: String = "tutorial_start"
@export var initial_location_id: String = "tutorial_temple"

func _init() -> void:
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
	_mapviz.highlight(_state.read(WorldState.LOCATION_ID_KEY), Color.RED)
	print("current location: " + get_location())

func get_world_state() -> WorldState:
	return _state

