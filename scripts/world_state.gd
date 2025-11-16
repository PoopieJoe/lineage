extends Node
class_name WorldState

var data: Dictionary = {}

func set_state(key: String, value):
    Logger.info("WorldState: world key '%s' set to %s" % [key, str(value)])
    data[key] = value

func get_state(key: String):
    if key in data:
        return data[key]
    else:
        Logger.error("WorldState: Key '%s' not found in state data." % key)
        return null