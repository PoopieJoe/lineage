extends Node
class_name WorldState

var data: Dictionary = {}

const LOCATION_ID_KEY: String = "location_id"
const LOCATION_NAME_KEY: String = "location_name"
const TIME_KEY: String = "time"
const DATE_KEY: String = "date"

func write(property: StringName, value: Variant) -> bool:
    Logger.info("SET %s=%s:%s" % [property, str(value), type_string(typeof(value))])
    data[property] = value
    return true

func read(property: StringName) -> Variant:
    var keys = data.keys()
    if property in keys:
        return data[property]
    else:
        return null