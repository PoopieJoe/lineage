class_name EventFactory
extends EventBuilder

static func get_builder(event_type: String) -> EventBuilder:
	var builder = EventBuilder.new()
	builder.set_identifier(event_type)
	match event_type:
		"sword_event":
			builder.add_paragraph("Test Event:") \
				.add_paragraph("You find a sword on the road. It appears to be in good condition, will you take it with you?") \
				.add_image("assets/sword.png") \
				.add_paragraph(" Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_text(" Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_text(" Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_text(" Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_paragraph(" Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_text(" Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_choice("Pick up the sword", "sword_event_pickup") \
				.add_choice("Leave it and move on", "sword_event_leave") 
		
		"sword_event_pickup":
			builder.add_paragraph("Next event:") \
				.add_paragraph("You chose to pick up the sword. It's not as nice as you thought it was,so you put it back on the ground where it came from, and continue your journey.") \
				.add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_choice("Continue", "sword_event") 

		"sword_event_leave":
			builder.add_paragraph("You chose to leave the sword behind and continue your journey.")\
				# .add_paragraph("Quis rerum est explicabo pariatur rerum iure. Quo vel id aut repudiandae autem. Dolorem id aut vel dolor accusamus voluptas ullam corporis. Perspiciatis suscipit repellat rerum laudantium. Dolore quia corrupti quia est sunt corporis dolor.") \
				.add_choice("Continue", "sword_event") 
		_:
			Logger.error("Event type <%s> not recognized" % event_type)
	return builder
