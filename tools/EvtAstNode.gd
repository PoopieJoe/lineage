extends RefCounted
class_name EvtASTNode

## Base class for all AST nodes

enum NodeType {
	ROOT, # Root node containing all statements
	FUNCTION_CALL, # Function calls like TAG(), ADDTEXT()
	IF_STATEMENT, # IF(...) { ... } ELSE { ... }
	WHILE_STATEMENT, # WHILE(...) { ... }
	BLOCK, # { ... }
	STRING_LITERAL, # "text"
	NUMBER_LITERAL, # 123, 4.5
	IDENTIFIER, # Variable names
	UNARY_EXPRESSION, # NOT expression
}

var type: NodeType
var children: Array[Array] = []
var value: Variant = null
var line: int = 0
var column: int = 0

func _init(p_type: NodeType, p_value: Variant = null, p_line: int = 0, p_column: int = 0):
	type = p_type
	value = p_value
	line = p_line
	column = p_column

func add_printable_child(name: String, node: EvtASTNode) -> void:
	children.append([name, node])

func _to_string() -> String:
	return _to_string_recursive("root", 0)

func _to_string_recursive(child_id: String, indent: int) -> String:
	var indent_str = "  ".repeat(indent)
	var result = "%s%s:%s" % [indent_str, child_id, NodeType.keys()[type]]
	
	if value != null:
		result += "=%s" % str(value)
	
	result += "\n"
	
	for child in children:
		if child[1] is EvtASTNode:
			result += child[1]._to_string_recursive(child[0], indent + 1)
	
	return result

## Specific node types for convenience

class ProgramNode extends EvtASTNode:
	var statements: Array[EvtASTNode] = []
	func _init():
		super._init(NodeType.ROOT)

	func add_statement(statement: EvtASTNode) -> void:
		statements.append(statement)
		add_printable_child("statement", statement)

class FunctionCallNode extends EvtASTNode:
	var function_name: String
	var arguments: Array[EvtASTNode] = []
	
	func _init(p_name: String, p_line: int = 0, p_column: int = 0):
		super._init(NodeType.FUNCTION_CALL, p_name, p_line, p_column)
		function_name = p_name
	
	func add_argument(arg: EvtASTNode) -> void:
		arguments.append(arg)
		add_printable_child("argument", arg)

class IfStatementNode extends EvtASTNode:
	var condition: EvtASTNode
	var then_block: EvtASTNode
	var else_block: EvtASTNode
	
	func _init(p_condition: EvtASTNode, p_line: int = 0, p_column: int = 0):
		super._init(NodeType.IF_STATEMENT, null, p_line, p_column)
		condition = p_condition
		add_printable_child("condition", condition)
	
	func set_then_block(block: EvtASTNode) -> void:
		then_block = block
		add_printable_child("then_block", then_block)

	func set_else_block(block: EvtASTNode) -> void:
		else_block = block
		add_printable_child("else_block", else_block)

class WhileStatementNode extends EvtASTNode:
	var condition: EvtASTNode
	var body_block: EvtASTNode
	
	func _init(p_condition: EvtASTNode, p_line: int = 0, p_column: int = 0):
		super._init(NodeType.WHILE_STATEMENT, null, p_line, p_column)
		condition = p_condition
		add_printable_child("condition", condition)
	
	func set_body_block(block: EvtASTNode) -> void:
		body_block = block
		add_printable_child("body_block", body_block)

class BlockNode extends EvtASTNode:
	var statements: Array[EvtASTNode] = []
	
	func _init(p_line: int = 0, p_column: int = 0):
		super._init(NodeType.BLOCK, null, p_line, p_column)
	
	func add_statement(statement: EvtASTNode) -> void:
		statements.append(statement)
		add_printable_child("statement", statement)

class StringLiteralNode extends EvtASTNode:
	var string_value: String
	
	func _init(p_value: String, p_line: int = 0, p_column: int = 0):
		super._init(NodeType.STRING_LITERAL, p_value, p_line, p_column)
		string_value = p_value

class NumberLiteralNode extends EvtASTNode:
	var number_value: float
	
	func _init(p_value: float, p_line: int = 0, p_column: int = 0):
		super._init(NodeType.NUMBER_LITERAL, p_value, p_line, p_column)
		number_value = p_value

class IdentifierNode extends EvtASTNode:
	var identifier_name: String
	
	func _init(p_name: String, p_line: int = 0, p_column: int = 0):
		super._init(NodeType.IDENTIFIER, p_name, p_line, p_column)
		identifier_name = p_name

class UnaryExpressionNode extends EvtASTNode:
	var operator: String
	var operand: EvtASTNode
	
	func _init(p_operator: String, p_operand: EvtASTNode, p_line: int = 0, p_column: int = 0):
		super._init(NodeType.UNARY_EXPRESSION, p_operator, p_line, p_column)
		operator = p_operator
		operand = p_operand
		add_printable_child("operand", operand)