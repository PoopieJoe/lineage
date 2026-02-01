extends EventNode
class_name BranchNode

var _parent: EventNode

func _init(parent: EventNode, condition: String = ""):
	super ("branch", parent)
	_parent = parent
	if condition != "":
		set_condition(condition)

func get_parent_branch() -> EventNode:
	return _parent

func has_parent_branch() -> bool:
	return _parent != null

func has_condition() -> bool:
	return has("condition")

func get_condition() -> String:
	return get_content("condition")

func set_condition(condition: String):
	set_content("condition", condition)
	
func extend(node: EventNode):
	set_next_node(node)

func evaluate(state: WorldState) -> bool:
	if not has_condition():
		return true
	var val = state.read(get_condition())
	if val == null:
		val = false
	var result = val as bool
	Logger.info("EVAL %s=%s" % [get_condition(), str(result)])
	return result

func build(_state: WorldState) -> EventNode:
	if not evaluate(_state):
		return null
	else:
		return super.build(_state)