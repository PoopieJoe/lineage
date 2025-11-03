class_name SwordEvent 
extends EventBuilder

func _init():
	super()
	self.add_text("You find a sword on the road. It appears to be in good condition, will you take it with you?") \
		.add_choice("Pick up the sword","pickup_sword") \
		.add_choice("Leave it and move on","leave_sword")
