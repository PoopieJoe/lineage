extends EventNode
class_name BranchNode

func _init(condition: String):
	super ("branch")
	set_condition(condition)

func get_condition() -> String:
	return get_content("condition")

func set_condition(condition: String):
	set_content("condition", condition)
	
func evaluate(state: WorldState) -> bool:
	var val = state.read(get_condition())
	if val == null:
		Logger.warning("'%s' not found in WorldState" % get_condition())
		val = false
	var result = val as bool
	Logger.info("Condition '%s' evaluated %s" % [get_condition(), str(result)])
	return result

func build(_state: WorldState) -> EventNode:
	if not evaluate(_state):
		return null
	else:
		return super.build(_state)