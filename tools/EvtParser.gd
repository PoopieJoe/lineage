extends RefCounted
class_name EVTParser

## Parser that converts tokens into an Abstract Syntax Tree (AST)

var tokens: Array[EvtTokenizer.Token] = []
var current_position: int = 0

func _init(p_tokens: Array[EvtTokenizer.Token] = []):
	tokens = p_tokens

## Parse the entire token stream into an AST
func parse() -> EvtASTNode.ProgramNode:
	var program = EvtASTNode.ProgramNode.new()
	current_position = 0
	
	while not _match([EvtTokenizer.TokenType.EOF]):
		# Skip newlines at the top level
		if _match([EvtTokenizer.TokenType.NEWLINE]):
			continue
		
		var statement = _parse_statement()
		if statement:
			program.add_statement(statement)
	
	return program

## Parse a single statement
func _parse_statement() -> EvtASTNode:
	# Skip newlines
	while _match([EvtTokenizer.TokenType.NEWLINE]):
		pass
	
	if _match([EvtTokenizer.TokenType.EOF]):
		return null
	
	# Check for control flow statements
	if _check(EvtTokenizer.TokenType.IDENTIFIER):
		var identifier = _peek()
		
		match identifier.value:
			"IF":
				return _parse_if_statement()
			"WHILE":
				return _parse_while_statement()
			_:
				# Regular function call or identifier
				return _parse_expression_statement()
	
	# Block statement
	if _check(EvtTokenizer.TokenType.LEFT_BRACE):
		return _parse_block()
	
	# Expression statement
	return _parse_expression_statement()

## Parse an IF statement: IF(condition) { ... } ELSE { ... }
func _parse_if_statement() -> EvtASTNode.IfStatementNode:
	var if_token = _consume(EvtTokenizer.TokenType.IDENTIFIER, "Expected 'IF'")
	
	_consume(EvtTokenizer.TokenType.LEFT_PAREN, "Expected '(' after 'IF'")
	var condition = _parse_expression()
	_consume(EvtTokenizer.TokenType.RIGHT_PAREN, "Expected ')' after condition")
	
	_skip_newlines()
	
	var if_node = EvtASTNode.IfStatementNode.new(condition, if_token.line, if_token.column)
	
	# Parse then block
	var then_block = _parse_block()
	if_node.set_then_block(then_block)
	
	_skip_newlines()

	# Parse else block
	if _check(EvtTokenizer.TokenType.IDENTIFIER):
		var identifier = _peek()
		if identifier.value == "ELSE":
			_consume(EvtTokenizer.TokenType.IDENTIFIER, "Expected 'ELSE'")
			_skip_newlines()
			var else_block = _parse_block()
			if_node.set_else_block(else_block)
			_skip_newlines()
	
	return if_node

## Parse a WHILE statement: WHILE(condition) { ... }
func _parse_while_statement() -> EvtASTNode.WhileStatementNode:
	var while_token = _consume(EvtTokenizer.TokenType.IDENTIFIER, "Expected 'WHILE'")
	
	_consume(EvtTokenizer.TokenType.LEFT_PAREN, "Expected '(' after 'WHILE'")
	var condition = _parse_expression()
	_consume(EvtTokenizer.TokenType.RIGHT_PAREN, "Expected ')' after condition")
	
	_skip_newlines()
	
	var while_node = EvtASTNode.WhileStatementNode.new(condition, while_token.line, while_token.column)
	
	# Parse body block
	var body_block = _parse_block()
	while_node.set_body_block(body_block)
	
	return while_node

## Parse a block: { ... }
func _parse_block() -> EvtASTNode.BlockNode:
	var start_token = _consume(EvtTokenizer.TokenType.LEFT_BRACE, "Expected '{'")
	var block = EvtASTNode.BlockNode.new(start_token.line, start_token.column)
	
	_skip_newlines()
	
	while not (_check(EvtTokenizer.TokenType.RIGHT_BRACE) or _match([EvtTokenizer.TokenType.EOF])):
		var statement = _parse_statement()
		if statement:
			block.add_statement(statement)
		_skip_newlines()
	
	_consume(EvtTokenizer.TokenType.RIGHT_BRACE, "Expected '}'")
	
	return block

## Parse an expression statement (function call or expression followed by newline/EOF)
func _parse_expression_statement() -> EvtASTNode:
	var expr = _parse_expression()
	_skip_newlines()
	return expr

## Parse an expression
func _parse_expression() -> EvtASTNode:
	return _parse_unary()

## Parse unary expressions
func _parse_unary() -> EvtASTNode:
	if _match([EvtTokenizer.TokenType.UNARY]):
		var operator_token = _previous()
		var operand = _parse_unary()
		return EvtASTNode.UnaryExpressionNode.new(operator_token.value, operand, operator_token.line, operator_token.column)
	
	return _parse_primary()

## Parse primary expressions (function calls, literals, identifiers)
func _parse_primary() -> EvtASTNode:
	# String literal
	if _match([EvtTokenizer.TokenType.STRING]):
		var token = _previous()
		return EvtASTNode.StringLiteralNode.new(token.value, token.line, token.column)
	
	# Number literal
	if _match([EvtTokenizer.TokenType.NUMBER]):
		var token = _previous()
		return EvtASTNode.NumberLiteralNode.new(float(token.value), token.line, token.column)
	
	# Identifier or function call
	if _match([EvtTokenizer.TokenType.IDENTIFIER]):
		var token = _previous()
		
		# Check if it's a function call
		if _check(EvtTokenizer.TokenType.LEFT_PAREN):
			return _parse_function_call(token)
		else:
			# Just an identifier
			return EvtASTNode.IdentifierNode.new(token.value, token.line, token.column)
	
	# Parenthesized expression
	if _match([EvtTokenizer.TokenType.LEFT_PAREN]):
		var expr = _parse_expression()
		_consume(EvtTokenizer.TokenType.RIGHT_PAREN, "Expected ')' after expression")
		return expr
	
	_error("Unexpected token: " + _peek().value)
	return null

## Parse a function call: FUNCTION(arg1, arg2, ...)
func _parse_function_call(name_token: EvtTokenizer.Token) -> EvtASTNode.FunctionCallNode:
	var func_call = EvtASTNode.FunctionCallNode.new(name_token.value, name_token.line, name_token.column)
	
	_consume(EvtTokenizer.TokenType.LEFT_PAREN, "Expected '(' after function name")
	
	# Parse arguments
	if not _check(EvtTokenizer.TokenType.RIGHT_PAREN):
		while true:
			var arg = _parse_expression()
			func_call.add_argument(arg)
			
			if not _match([EvtTokenizer.TokenType.COMMA]):
				break
	
	_consume(EvtTokenizer.TokenType.RIGHT_PAREN, "Expected ')' after arguments")
	
	return func_call

## Helper methods for token navigation

func _peek() -> EvtTokenizer.Token:
	return tokens[current_position]

func _previous() -> EvtTokenizer.Token:
	return tokens[current_position - 1]

func _advance() -> EvtTokenizer.Token:
	current_position += 1
	return _previous()

func _check(type: EvtTokenizer.TokenType) -> bool:
	return _peek().type == type

func _match(types: Array) -> bool:
	for type in types:
		if _check(type):
			_advance()
			return true
	return false

func _consume(type: EvtTokenizer.TokenType, message: String) -> EvtTokenizer.Token:
	if _check(type):
		return _advance()
	
	_error(message)
	return _peek()

func _skip_newlines() -> void:
	while _match([EvtTokenizer.TokenType.NEWLINE]):
		pass

func _error(message: String) -> void:
	var token = _peek()
	push_error("Parse error at line %d, column %d: %s" % [token.line, token.column, message])
