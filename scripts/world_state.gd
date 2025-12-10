extends Node
class_name WorldState

var data: Dictionary = {}

const LOCATION_KEY: String = "location"

func set_state(key: String, value):
    Logger.info("SET %s=%s:%s" % [key, str(value), type_string(typeof(value))])
    data[key] = value

func get_state(key: String):
    if key in data:
        return data[key]
    else:
        Logger.error("WorldState: Key '%s' not found in state data." % key)
        return null