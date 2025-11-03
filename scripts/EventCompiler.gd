class_name EventCompiler

static func parse( content: EventNode ) -> String:
	var newcontent : String = ""
	assert(content.get_type() == "root")
	for node in content.children:
		match (node.get_type()):
			TextNode.type:
				newcontent += node.content + '\n'
			ImageNode.type:
				newcontent += node.content + '\n'
			ChoiceNode.type:
				newcontent += node.text + '\n'
			_:
				push_error("Node of undefined type <%s>" % node.get_type())
	return newcontent
