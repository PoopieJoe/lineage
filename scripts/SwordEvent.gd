class_name SwordEvent extends Event

func _init() -> void:
	prompt = "You find a sword on the road. It appears to be in good condition, will you take it with you?"
	_add_choice(
		"Pick up the sword",
		func(): return true,
		func(): return null )
	_add_choice(
		"Leave it and move on",
		func(): return true,
		func(): return null )

func precond() -> bool:
	return true
