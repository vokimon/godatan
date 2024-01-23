class_name InteractiveCamera2D
extends Camera2D

## Zoom factor step (factor additive)
@export var zoom_increment := 0.05
## Minimal zoom factor
@export var zoom_min := 0.05
## Maximal zoom factor
@export var zoom_max := 4.0
## True to scroll keeping the mouse position, if not will zoom on the center
@export var zoom_to_position := false
## Initial zoom factor
@export var zoom_level := 0.5:
	set(level):
		zoom_level = clamp(level, zoom_min, zoom_max)
		zoom = zoom_level * Vector2.ONE

var panning := false

func event_processed():
	get_tree().get_root().set_input_as_handled()

func _ready():
	self.zoom_level = zoom_level
	# Only enable the camera which is child of the toplevel node
	# Convenience to have a testing cameras for each scene
	enabled = get_parent() == get_tree().get_current_scene()

func zoom_step(value):
	self.zoom_level = zoom_level + value * zoom_increment

func _unhandled_input(event: InputEvent) -> void:
	if not is_current(): return
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
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			global_position -= event.relative / zoom_level
		else:
			panning = false
		event_processed()
		return
