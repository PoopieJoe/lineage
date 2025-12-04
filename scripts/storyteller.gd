extends Node
class_name Storyteller

var _event_database: EventDatabase
var _world_state: WorldState
var _current_event: EventRootNode = null
var _past_events: Array[EventRootNode] = []
@export var initial_event_id: String = "test"
signal event_resolved(new_event: EventRootNode)

func _init() -> void:
    _world_state = WorldState.new()
    _event_database = EventDatabase.new()
    _event_database.load_events("res://events")
    add_child(_world_state)

func _ready() -> void:
    _current_event = _event_database.get_event(initial_event_id).build(_world_state)

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