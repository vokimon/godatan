extends InteractiveCamera2D

func emulate_dice(value):
	get_parent().dice_rolled(value)

func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if not is_current(): return
	if event is InputEventKey:
		if event.pressed == false: return super(event)
		match event.keycode:
			KEY_1: emulate_dice(2)
			KEY_2: emulate_dice(3)
			KEY_3: emulate_dice(4)
			KEY_4: emulate_dice(5)
			KEY_5: emulate_dice(6)
			KEY_6: emulate_dice(8)
			KEY_7: emulate_dice(9)
			KEY_8: emulate_dice(10)
			KEY_9: emulate_dice(11)
			KEY_0: emulate_dice(12)
			KEY_PLUS: emulate_dice(7)
			_: return super(event)
		event_processed()
