class_name ContentParser

static func parse(content:String) -> String:
	var newcontent : String = ""
	for line in content.split('\n'):
		newcontent += line + '\n'
	return newcontent
