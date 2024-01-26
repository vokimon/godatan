extends Node2D

const OUTER_RADIUS = 36
const INNER_RADIUS = 32
const OUTER_COLOR_HIGHLIGHT = Color.DARK_GOLDENROD
const INNER_COLOR_HIGHLIGHT = Color.YELLOW
const OUTER_COLOR = Color.BURLYWOOD
const INNER_COLOR = Color.WHEAT

@export var highlighted: bool = false:
	set(new_highlighted):
		if new_highlighted:
			$AnimationPlayer.play("popoutin")
		highlighted = new_highlighted
		queue_redraw()

@export var dice_number: int = 0:
	set(value):
		dice_number = value
		update_label()

static var frequencyStyle = {
	1: preload("res://label_settings/tile_number_freq1.tres"),
	2: preload("res://label_settings/tile_number_freq2.tres"),
	3: preload("res://label_settings/tile_number_freq3.tres"),
	4: preload("res://label_settings/tile_number_freq4.tres"),
	5: preload("res://label_settings/tile_number_freq5.tres"),
}

func update_label():
	visible = dice_number in [2,3,4,5,6,8,9,10,11,12]
	if not find_child('Number'): return
	if not dice_number: return
	var frequency = 6-abs(dice_number-7)
	if not frequency: return
	$Number.label_settings = frequencyStyle.get(frequency)
	$Number.text = "{n}\n{dots}".format({
		"n": dice_number,
		"dots": '˙'.repeat(frequency),
	})
	$Number.visible = visible

func _draw():
	draw_circle(Vector2.ZERO, OUTER_RADIUS, OUTER_COLOR_HIGHLIGHT if highlighted else OUTER_COLOR )
	draw_circle(Vector2.ZERO, INNER_RADIUS, INNER_COLOR_HIGHLIGHT if highlighted else INNER_COLOR)

func _ready():
	update_label()
