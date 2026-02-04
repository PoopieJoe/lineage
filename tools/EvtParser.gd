extends RefCounted
class_name EVTParser

## Parser that converts tokens into an Abstract Syntax Tree (AST)

var tokens: Array[EvtLexer.Token] = []
var current_position: int = 0

func _init(p_tokens: Array[EvtLexer.Token] = []):
	tokens = p_tokens

## Parse the entire token stream into an AST
func parse() -> EvtASTNode.RootNode:
	var program = EvtASTNode.RootNode.new()
	current_position = 0
	
	while not _match([EvtLexer.TokenType.EOF]):
		# Skip newlines at the top level
		if _match([EvtLexer.TokenType.NEWLINE]):
			continue
		
		var statement = _parse_statement()
		if statement:
			program.add_statement(statement)
		else:
			return null
	
	return program

## Parse a single statement
func _parse_statement() -> EvtASTNode:
	# Skip newlines
	while _match([EvtLexer.TokenType.NEWLINE]):
		pass
	
	if _match([EvtLexer.TokenType.EOF]):
		return null

	# Check for control flow statements
	if _check(EvtLexer.TokenType.KEYWORD):
		var keyword = _peek()
		
		match EvtLexer.Keywords[keyword.value]:
			EvtLexer.Keywords.IF:
				return _parse_if()
			EvtLexer.Keywords.WHILE:
				return _parse_while()
			EvtLexer.Keywords.TAG:
				return _parse_tag()
			EvtLexer.Keywords.HEADER:
				return _parse_header()
			EvtLexer.Keywords.VSPACE:
				return _parse_vspace()
			EvtLexer.Keywords.CHOICE:
				return _parse_choice()
			_:
				_error("Unhandled keyword: %s" % keyword.value)
				return null
	
	if _check(EvtLexer.TokenType.STRING):
		return _parse_string()
	
	# Block statement
	if _check(EvtLexer.TokenType.LBRACE):
		return _parse_block()
	
	if _check(EvtLexer.TokenType.IDENTIFIER) and _next().type == EvtLexer.TokenType.ASSIGN:
		return _parse_assignment()

	# Unhandled statement
	_error("Unhandled token: %s" % _peek().value)
	return null

## Parse an IF statement: IF(condition) { ... } ELSE { ... }
func _parse_if() -> EvtASTNode.IfNode:
	var if_token = _consume(EvtLexer.TokenType.KEYWORD, "Expected 'IF'")
	
	_consume(EvtLexer.TokenType.LPAREN, "Expected '(' after 'IF'")
	var condition = null
	if _next().type == EvtLexer.TokenType.COMPARE:
		condition = _parse_comparison()
	else:
		condition = _parse_expression()
	_consume(EvtLexer.TokenType.RPAREN, "Expected ')' after condition")
	
	_skip_newlines()
	
	var if_node = EvtASTNode.IfNode.new(condition, if_token.line, if_token.column)
	
	# Parse then block
	var then_block = _parse_block()
	if_node.set_then_block(then_block)
	
	_skip_newlines()

	# Parse else block
	if _check(EvtLexer.TokenType.KEYWORD):
		var keyword = _peek()
		if keyword.value == "ELSE":
			_consume(EvtLexer.TokenType.KEYWORD, "Expected 'ELSE'")
			_skip_newlines()
			var else_block = _parse_block()
			if_node.set_else_block(else_block)
			_skip_newlines()
	
	return if_node

## Parse a WHILE statement: WHILE(condition) { ... }
func _parse_while() -> EvtASTNode.WhileNode:
	var while_token = _consume(EvtLexer.TokenType.KEYWORD, "Expected 'WHILE'")
	
	_consume(EvtLexer.TokenType.LPAREN, "Expected '(' after 'WHILE'")
	var condition = _parse_expression()
	_consume(EvtLexer.TokenType.RPAREN, "Expected ')' after condition")
	
	_skip_newlines()
	
	var while_node = EvtASTNode.WhileNode.new(condition, while_token.line, while_token.column)
	
	# Parse body block
	var body_block = _parse_block()
	while_node.set_body_block(body_block)
	
	return while_node

func _parse_unary() -> EvtASTNode.UnaryExpressionNode:
	var operator = _consume(EvtLexer.TokenType.UNARY, "Expected unary expression")
	var operand = _parse_expression()
	return EvtASTNode.UnaryExpressionNode.new(operator.value, operand, operator.line, operator.column)

func _parse_comparison() -> EvtASTNode.ComparisonNode:
	var start_token = _peek()
	var l_operand = _parse_expression()
	var operator = _consume(EvtLexer.TokenType.COMPARE, "Expected unary expression")
	var r_operand = _parse_expression()
	return EvtASTNode.ComparisonNode.new(operator.value, l_operand, r_operand, start_token.line, start_token.column)

func _parse_expression() -> EvtASTNode:
	if _check(EvtLexer.TokenType.UNARY):
		return _parse_unary()
	if _check(EvtLexer.TokenType.NUMBER):
		return _parse_number()
	if _check(EvtLexer.TokenType.IDENTIFIER):
		return _parse_identifier()
	if _check(EvtLexer.TokenType.KEYWORD):
		return _parse_choice()
	_error("Failed to parse expression of type " + EvtLexer.TokenType.keys()[_peek().type])
	return null

func _parse_tag() -> EvtASTNode.TagNode:
	var start_token = _consume(EvtLexer.TokenType.KEYWORD, "Expected 'TAG'")
	_consume(EvtLexer.TokenType.LPAREN, "Expected '(' after 'TAG'")
	var expr = _parse_string()
	_consume(EvtLexer.TokenType.RPAREN, "Expected ')' after expression")
	_skip_newlines()
	return EvtASTNode.TagNode.new(expr.value, start_token.line, start_token.column)

func _parse_header() -> EvtASTNode.HeaderNode:
	var header = _consume(EvtLexer.TokenType.KEYWORD, "Expected 'HEADER'")
	_skip_newlines()
	return EvtASTNode.HeaderNode.new(header.line, header.column)

func _parse_vspace() -> EvtASTNode.VspaceNode:
	var start_token = _consume(EvtLexer.TokenType.KEYWORD, "Expected 'VSPACE'")
	_consume(EvtLexer.TokenType.LPAREN, "Expected '(' after 'VSPACE'")
	var expr = _consume(EvtLexer.TokenType.NUMBER, "Expected NUMBER after '('")
	_consume(EvtLexer.TokenType.RPAREN, "Expected ')' after expression")
	_skip_newlines()
	return EvtASTNode.VspaceNode.new(float(expr.value), start_token.line, start_token.column)

func _parse_identifier() -> EvtASTNode.IdentifierNode:
	var identifier_token = _consume(EvtLexer.TokenType.IDENTIFIER, "Expected identifier")
	return EvtASTNode.IdentifierNode.new(identifier_token.value, identifier_token.line, identifier_token.column)

func _parse_assignment() -> EvtASTNode.AssignNode:
	var start_token = _peek()
	var identifier = _parse_identifier()
	_consume(EvtLexer.TokenType.ASSIGN, "Expected '='")
	var expression = _parse_expression()
	return EvtASTNode.AssignNode.new(identifier, expression, start_token.line, start_token.column)

func _parse_choice() -> EvtASTNode.ChoiceNode:
	var start_token = _consume(EvtLexer.TokenType.KEYWORD, "Expected 'CHOICE'")
	var choice = EvtASTNode.ChoiceNode.new(start_token.line, start_token.column)
	_skip_newlines()
	_consume(EvtLexer.TokenType.LBRACE, "Expected '{' after 'CHOICE'")
	_skip_newlines()
	while not (_check(EvtLexer.TokenType.RBRACE) or _match([EvtLexer.TokenType.EOF])):
		_skip_newlines()
		var identifier = _parse_identifier()
		if not identifier:
			return null

		var condition = null
		if _match([EvtLexer.TokenType.LPAREN]):
			if _next().type == EvtLexer.TokenType.COMPARE:
				condition = _parse_comparison()
			else:
				condition = _parse_expression()
			_consume(EvtLexer.TokenType.RPAREN, "Expected ')' after condition")
		_skip_newlines()

		var block = _parse_block()
		if not block:
			return null
		_skip_newlines()

		choice.add_option(identifier, condition, block)

	_skip_newlines()
	_consume(EvtLexer.TokenType.RBRACE, "Expected '}'")
	_skip_newlines()
	return choice

## Parse a block: { ... }
func _parse_block() -> EvtASTNode.BlockNode:
	var start_token = _consume(EvtLexer.TokenType.LBRACE, "Expected '{'")
	var block = EvtASTNode.BlockNode.new(start_token.line, start_token.column)
	
	_skip_newlines()
	
	while not (_check(EvtLexer.TokenType.RBRACE) or _match([EvtLexer.TokenType.EOF])):
		var statement = _parse_statement()
		if statement:
			block.add_statement(statement)
		else:
			return null
		_skip_newlines()
	
	_consume(EvtLexer.TokenType.RBRACE, "Expected '}'")
	
	return block

func _parse_string() -> EvtASTNode.StringLiteralNode:
	var string = _consume(EvtLexer.TokenType.STRING, "Expected string literal")
	_skip_newlines()
	return EvtASTNode.StringLiteralNode.new(string.value, string.line, string.column)

func _parse_number() -> EvtASTNode.NumberLiteralNode:
	var number = _consume(EvtLexer.TokenType.NUMBER, "Expected number literal")
	_skip_newlines()
	return EvtASTNode.NumberLiteralNode.new(float(number.value), number.line, number.column)

## Helper methods for token navigation
func _next() -> EvtLexer.Token:
	return tokens[current_position + 1]

func _peek() -> EvtLexer.Token:
	return tokens[current_position]

func _previous() -> EvtLexer.Token:
	return tokens[current_position - 1]

func _advance() -> EvtLexer.Token:
	current_position += 1
	return _previous()

func _check(type: EvtLexer.TokenType) -> bool:
	return _peek().type == type

func _match(types: Array) -> bool:
	for type in types:
		if _check(type):
			_advance()
			return true
	return false

func _consume(type: EvtLexer.TokenType, message: String) -> EvtLexer.Token:
	if _check(type):
		return _advance()
	
	_error(message)
	return _peek()

func _skip_newlines() -> void:
	while _match([EvtLexer.TokenType.NEWLINE]):
		pass

func _error(message: String) -> void:
	var token = _peek()
	push_error("Parse error at line %d, column %d: %s" % [token.line, token.column, message])
