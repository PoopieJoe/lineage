class_name EvtLexer
## This Lexer was co-authored by Claude (Sonnet 4.5)

enum TokenType {
    EOF,
    IDENTIFIER, # Variable names, function names
    STRING, # String literals in quotes
    NUMBER, # Numeric literals
    LPAREN, # (
    RPAREN, # )
    LBRACE, # {
    RBRACE, # }
    UNARY, # Unary operators
    NEWLINE, # Line breaks
    KEYWORD, # Keywords
}

enum Keywords {NOT, IF, ELSE, WHILE, TAG, HEADER, CHOICE, CHOSEN, VSPACE}

## Represents a single token
class Token:
    var type: TokenType
    var value: String
    var line: int
    var column: int
    var length: int
    
    func _init(p_type: TokenType, p_value: String, p_line: int, p_column: int, p_length):
        type = p_type
        value = p_value
        line = p_line
        column = p_column
        length = p_length
    
    func _to_string() -> String:
        return "Token(%s, '%s', Line: %d, Col: %d, Len: %d)" % [
            TokenType.keys()[type], value, line, column, length
        ]

var source: String = ""
var position: int = 0
var line: int = 1
var column: int = 1
var tokens: Array[Token] = []

## Initialize the tokenizer with source code
func _init(p_source: String = ""):
    source = p_source

## Tokenize the entire source
func tokenize() -> Array[Token]:
    tokens.clear()
    position = 0
    line = 1
    column = 1
    
    while position < source.length():
        _skip_whitespace_except_newlines()
        
        if position >= source.length():
            break
        
        var current_char = source[position]
        
        # Handle comments
        if current_char == '/' and _peek() == '/':
            _skip_line_comment()
            continue
        
        if current_char == '/' and _peek() == '*':
            _skip_block_comment()
            continue
        
        # Handle newlines
        if current_char == '\n':
            _add_token(TokenType.NEWLINE, "\\n", line, column, 2)
            _advance()
            line += 1
            column = 1
            continue
        
        # Handle strings
        if current_char == '"':
            _tokenize_string()
            continue
        
        # Handle numbers
        if current_char.is_valid_float() or (current_char == '-' and _peek().is_valid_float()):
            _tokenize_number()
            continue
        
        # Handle identifiers and keywords
        if current_char.is_valid_identifier():
            _tokenize_identifier()
            continue
        
        # Handle single-character tokens
        match current_char:
            '(':
                _add_token(TokenType.LPAREN, "(", line, column, 1)
                _advance()
            ')':
                _add_token(TokenType.RPAREN, ")", line, column, 1)
                _advance()
            '{':
                _add_token(TokenType.LBRACE, "{", line, column, 1)
                _advance()
            '}':
                _add_token(TokenType.RBRACE, "}", line, column, 1)
                _advance()
            _:
                push_error("Unexpected character '%s' at line %d, column %d" % [current_char, line, column])
                break
    
    _add_token(TokenType.EOF, "", line, column, 0)
    return tokens

## Get current character
func _current() -> String:
    if position >= source.length():
        return ""
    return source[position]

## Peek at next character without advancing
func _peek(offset: int = 1) -> String:
    var peek_pos = position + offset
    if peek_pos >= source.length():
        return ""
    return source[peek_pos]

## Advance position and column
func _advance() -> void:
    position += 1
    column += 1

## Skip whitespace except newlines
func _skip_whitespace_except_newlines() -> void:
    while position < source.length():
        var c = source[position]
        if c == ' ' or c == '\t' or c == '\r':
            _advance()
        else:
            break

## Skip line comments (//)
func _skip_line_comment() -> void:
    while position < source.length() and source[position] != '\n':
        _advance()

## Skip block comments (/* */)
func _skip_block_comment() -> void:
    _advance() # Skip /
    _advance() # Skip *
    
    while position < source.length():
        if source[position] == '*' and _peek() == '/':
            _advance() # Skip *
            _advance() # Skip /
            break
        if source[position] == '\n':
            line += 1
            column = 1
        _advance()

## Tokenize string literals
func _tokenize_string() -> void:
    var start_line = line
    var start_column = column
    var string_value = ""
    
    _advance() # Skip opening quote
    
    while position < source.length() and source[position] != '"':
        var c = source[position]
        
        # Handle escape sequences
        if c == '\\' and position + 1 < source.length():
            _advance()
            var escaped = source[position]
            match escaped:
                'n':
                    string_value += '\n'
                't':
                    string_value += '\t'
                'r':
                    string_value += '\r'
                '"':
                    string_value += '"'
                '\\':
                    string_value += '\\'
                _:
                    string_value += escaped
            _advance()
        else:
            if c == '\n':
                line += 1
                column = 1
            string_value += c
            _advance()
    
    if position >= source.length():
        push_error("Unterminated string at line %d, column %d" % [start_line, start_column])
        return
    
    _advance() # Skip closing quote
    
    _add_token(TokenType.STRING, string_value, start_line, start_column, len(string_value))

## Tokenize numbers
func _tokenize_number() -> void:
    var start_column = column
    var number_str = ""
    var has_decimal = false
    
    # Handle negative sign
    if source[position] == '-':
        number_str += '-'
        _advance()
    
    while position < source.length():
        var c = source[position]
        
        if not c.is_valid_float():
            if c == '.' and not has_decimal:
                has_decimal = true
            else:
                break
        _advance()
        number_str += c
    
    _add_token(TokenType.NUMBER, number_str, line, start_column, len(number_str))

## Tokenize identifiers
func _tokenize_identifier() -> void:
    var start_column = column
    var identifier = ""
    
    while position < source.length():
        var c = source[position]
        if c.is_valid_identifier() or c.is_valid_int():
            identifier += c
            _advance()
        else:
            break

    var type = TokenType.IDENTIFIER
    if identifier in Keywords.keys():
        type = TokenType.KEYWORD
    _add_token(type, identifier, line, start_column, len(identifier))

func _add_token(type: TokenType, value: String, p_line: int, p_column: int, p_length: int) -> void:
    tokens.append(Token.new(type, value, p_line, p_column, p_length))

## Get all tokens as an array
func get_tokens() -> Array[Token]:
    return tokens