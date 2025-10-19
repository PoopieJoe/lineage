class_name EventGenerator

static func next() -> Event:
	return SwordEvent.new()

static func resolve(choice : String) -> Error:
	return OK
