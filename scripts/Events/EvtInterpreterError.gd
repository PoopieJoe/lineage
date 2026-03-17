extends RefCounted
class_name EVTInterpreterError

var line: int
var column: int
var message: String

func _init(p_node: EvtASTNode, p_message: String) -> void:
    line = p_node.line
    column = p_node.column
    message = p_message