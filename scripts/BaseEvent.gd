class_name Event

var choices : Array = Array()
var prompt : String = "PROMPT NOT GIVEN"

func precond() -> bool:
	return ERR_DOES_NOT_EXIST

func _add_choice(prompt : String, precond : Callable, effect : Callable) -> Error:
	if choices.find_custom(func(x): return x[0] == prompt) == -1:
		return ERR_ALREADY_EXISTS
	choices.append([prompt,precond,effect])
	return OK
