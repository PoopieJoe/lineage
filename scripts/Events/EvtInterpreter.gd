extends RefCounted
class_name EVTInterpreter

signal new_element(type, value)
signal element_interaction(type, value)
signal unpause(type, value)

var ns: Dictionary = {}
var flags: Dictionary = {}
var root: EvtASTNode = null
var _found_start = false

func _init(p_root: EvtASTNode.RootNode) -> void:
    root = p_root
    element_interaction.connect(_on_element_interaction)

func eval_statement(p_node: EvtASTNode) -> Variant:
    var result = await eval(p_node)
    if result is EVTInterpreterError:
        return result
        
    if result is String:
        new_element.emit("text", result)
    return result
    
func eval_condition(p_node: EvtASTNode) -> Variant:
    var result = await eval(p_node)
    if result is EVTInterpreterError:
        return result
    # for some reason if result is not already bool casting to bool directly causes an error
    # but inverting twice does not have this issue?
    return not not result 

func eval_root(p_node: EvtASTNode.RootNode) -> Variant:
    for statement in p_node.statements:
        var result = await eval_statement(statement)
        if result is EVTInterpreterError:
            return result
    return true

func eval_string_literal(p_node: EvtASTNode.StringLiteralNode) -> Variant:
    return p_node.value

func eval_choice(p_node: EvtASTNode.ChoiceNode) -> Variant:
    var options = []
    for element in p_node.options:
        var condition = true
        if element[1] != null:
            condition = await eval_condition(element[1])
            if condition is EVTInterpreterError:
                return condition
        options.append({"label": element[0].value, "condition": condition})

    new_element.emit("choice", options)

    var result = await wait_for_user("choice")
    var chosen_label = result[1]
    # Execute the block whose label matches the chosen one
    for element in p_node.options:
        if element[0].value == chosen_label:
            var block_result = await eval(element[2])
            if block_result is EVTInterpreterError:
                return block_result
            break
    return chosen_label

func eval_tag(p_node: EvtASTNode.TagNode) -> Variant:
    if _found_start:
        return EVTInterpreterError.new(p_node, "Tags not allowed after START")
    else:
        return true

func eval_start(p_node: EvtASTNode.StartNode) -> Variant:
    if _found_start:
        return EVTInterpreterError.new(p_node, "Found more than one START")
    else:
        _found_start = true
        return true

func eval_vspace(p_node: EvtASTNode.VspaceNode) -> Variant:
    new_element.emit("vspace", p_node.value)
    return p_node.value

func eval_while(p_node: EvtASTNode.WhileNode) -> Variant:
    var iterations = 0
    var condition = true
    while condition:
        iterations = iterations + 1
        if iterations > 10:
            return EVTInterpreterError.new(p_node, "While loop had too many iterations, breaking")
            
        condition = await eval_condition(p_node.condition)
        if condition is EVTInterpreterError:
            return condition
        elif condition:
            var result = await eval(p_node.body_block)
            if result is EVTInterpreterError:
                return result
    return true

func eval_block(p_node: EvtASTNode.BlockNode) -> Variant:
    for statement in p_node.statements:
        var result = await eval_statement(statement)
        if result is EVTInterpreterError:
            return result
    return true

func eval_unary(p_node: EvtASTNode.UnaryExpressionNode) -> Variant:
    if p_node.operator == "NOT":
        var result = await eval_condition(p_node.operand)
        if result is EVTInterpreterError:
            return result
        return not result
    return EVTInterpreterError.new(p_node, "Undefined unary operator: %s" % p_node.operator)

func eval_identifier(p_node: EvtASTNode.IdentifierNode) -> Variant:
    if ns.has(str(p_node.value)):
        return ns[str(p_node.value)]
    else:
        return EVTInterpreterError.new(p_node, "Identifier not defined: %s" % p_node.value)

func eval_assignment(p_node: EvtASTNode.AssignNode) -> Variant:
    var value = await eval(p_node.expression)
    if value is EVTInterpreterError:
        return value
    else:
        ns[str(p_node.identifier.value)] = value
        return true

func eval_if(p_node: EvtASTNode.IfNode) -> Variant:
    var condition = await eval_condition(p_node.condition)
    if condition is EVTInterpreterError:
        return condition
    elif condition:
        return await eval(p_node.then_block)
    else:
        if p_node.else_block:
            return await eval(p_node.else_block)
        else:
            return true

func eval_call(p_node: EvtASTNode.CallNode) -> Variant:
    var fn_name: String = p_node.value
    match fn_name:
        "SET_FLAG":
            if p_node.args.size() != 1:
                return EVTInterpreterError.new(p_node, "SET_FLAG expects exactly 1 argument")
            var flag_name = await eval(p_node.args[0])
            if flag_name is EVTInterpreterError:
                return flag_name
            flags[str(flag_name)] = true
            return true
        "CLEAR_FLAG":
            if p_node.args.size() != 1:
                return EVTInterpreterError.new(p_node, "CLEAR_FLAG expects exactly 1 argument")
            var flag_name = await eval(p_node.args[0])
            if flag_name is EVTInterpreterError:
                return flag_name
            flags.erase(str(flag_name))
            return true
        "GET_FLAG":
            if p_node.args.size() != 1:
                return EVTInterpreterError.new(p_node, "GET_FLAG expects exactly 1 argument")
            var flag_name = await eval(p_node.args[0])
            if flag_name is EVTInterpreterError:
                return flag_name
            return flags.has(str(flag_name)) and flags[str(flag_name)] == true
        _:
            return EVTInterpreterError.new(p_node, "Unknown function: %s" % fn_name)

func eval_compare(p_node: EvtASTNode.ComparisonNode) -> Variant:
    var left = await eval(p_node.l_operand)
    var right = await eval(p_node.r_operand)

    if p_node.operator == "==":
        if typeof(left) == typeof(right):
            return (left == right)
        else:
            return false
            
    return EVTInterpreterError.new(p_node, "Invalid comporison operator: %s" % p_node.operator)

func eval(p_node: EvtASTNode) -> Variant:
    match p_node.type:
        EvtASTNode.NodeType.ROOT:
            return await eval_root(p_node)
        EvtASTNode.NodeType.STRING_LITERAL:
            return eval_string_literal(p_node)
        EvtASTNode.NodeType.CHOICE:
            return await eval_choice(p_node)
        EvtASTNode.NodeType.TAG:
            return eval_tag(p_node)
        EvtASTNode.NodeType.START:
            return eval_start(p_node)
        EvtASTNode.NodeType.VSPACE:
            return eval_vspace(p_node)
        EvtASTNode.NodeType.WHILE:
            return await eval_while(p_node)
        EvtASTNode.NodeType.BLOCK:
            return await eval_block(p_node)
        EvtASTNode.NodeType.UNARY:
            return await eval_unary(p_node)
        EvtASTNode.NodeType.IDENTIFIER:
            return eval_identifier(p_node)
        EvtASTNode.NodeType.ASSIGNMENT:
            return await eval_assignment(p_node)
        EvtASTNode.NodeType.IF:
            return await eval_if(p_node)
        EvtASTNode.NodeType.COMPARE:
            return await eval_compare(p_node)
        EvtASTNode.NodeType.CALL:
            return await eval_call(p_node)
        _:
            return EVTInterpreterError.new(p_node, "Unhandled node: %s" % EvtASTNode.NodeType.keys()[p_node.type])
    
func merge_meta_dict(x: Dictionary, y: Dictionary, overwrite = false) -> Dictionary:
    var result = x.duplicate()
    for key in y.keys():
        if result.has(key):
            if result[key] is Array and y[key] is Array:
                result[key].append_array(y[key])
            elif result[key] is Dictionary and y[key] is Dictionary:
                merge_meta_dict(result[key], y[key])
            else:
                # don't overwrite existing entries or non-matching types
                if typeof(y[key]) != typeof(result[key]):
                    Logger.warning(
                        "Cannot merge key %s, value of type %s is incompatible with %s" % [
                            key, 
                            type_string(typeof(y[key])), 
                            type_string(typeof(result[key]))
                        ]
                    )
                if overwrite:
                    result[key] = y[key]
                else:
                    pass
                pass 
        else:
            result[key] = y[key]
    return result
                

func eval_meta(p_node: EvtASTNode) -> Dictionary:
    var result = {}
    match p_node.type:
        EvtASTNode.NodeType.ROOT:
            for statement in p_node.statements:
                var data = eval_meta(statement)
                if data.has("found_start"):
                    return result
                else:
                    result = merge_meta_dict(result, data)
        EvtASTNode.NodeType.TAG:
            if result.has("tags"):
                result["tags"].append(str(p_node.value))
            else:
                result["tags"] = [str(p_node.value)]
        EvtASTNode.NodeType.START:
            result["found_start"] = true
        _:
            pass
    return result

func run() -> void:
    _found_start = false
    var result = await eval(root)
    if result is EVTInterpreterError:
        var message = "Interpreter error at line %d, column %d: %s" % [result.line, result.column, result.message]
        Logger.error(message)

func meta() -> Dictionary:
    return eval_meta(root)

func create_interaction_filter(filter_type) -> Callable:
    var output = func _filter_interactions(type, value) -> void:
        if filter_type == type:
            unpause.emit(type, value)
    return output

func wait_for_user(type) -> Variant:
    var filter = create_interaction_filter(type)
    element_interaction.connect(filter)
    var result = await unpause
    element_interaction.disconnect(filter)
    return result

func _on_element_interaction(type, value) -> void:
    print("Interaction %s on %s" % [str(type), str(value)])
    return