extends Node
class_name EventDatabase

var _cache: Dictionary = {}

func load_events(path: String) -> void:
    var parser = EventParser.new()
    var events = parser.load_from_dir(path)
    var n = 0
    for id in events.keys():
        if not _cache.has(id):
            n += 1
            _cache[id] = events[id]
        else:
            Logger.warning("Duplicate event <%s>, skipping" % id)
    Logger.info("Loaded %d events from %s" % [n, path])

func get_event(event_id: String) -> EventBuilder:
    if not _cache.has(event_id):
        Logger.error("Event <%s> does not exist" % event_id)
        return EventBuilder.new()
    return _cache[event_id]