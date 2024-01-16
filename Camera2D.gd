extends Camera2D

const ZOOM_INCREMENT = 0.05
const ZOOM_MIN = 0.05
const ZOOM_MAX = 4.0	

var panning := false
var zoom_level := 0.5

func emulate_dice(value):
	get_parent().dice_rolled(value)

func _ready():
	zoom = zoom_level * Vector2.ONE

func event_processed():
	get_tree().get_root().set_input_as_handled()

func zoom_step(value):
	zoom_level = clamp(zoom_level + value * ZOOM_INCREMENT, ZOOM_MIN, ZOOM_MAX)
	zoom = zoom_level * Vector2.ONE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MIDDLE:
				panning = event.pressed == true
				event_processed()
			MOUSE_BUTTON_WHEEL_UP:
				zoom_step(+1)
				event_processed()
			MOUSE_BUTTON_WHEEL_DOWN:
				zoom_step(-1)
				event_processed()
		return
	if event is InputEventMouseMotion:
		if not panning: return
		event_processed()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			global_position -= event.relative / zoom_level
		else:
			panning = false
		return
	if event is InputEventKey:
		if event.pressed == false: return
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
