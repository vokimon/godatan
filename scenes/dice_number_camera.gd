extends Camera2D

func _input(event):
	# Only for testing purposes
	if not is_current(): return
	if event is InputEventMouseButton:
		if event.pressed == false: return
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var new_number = (get_parent().dice_number+1)%13
				get_parent().dice_number = new_number
			MOUSE_BUTTON_RIGHT:
				get_parent().highlighted = not get_parent().highlighted
