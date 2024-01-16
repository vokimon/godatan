extends Node2D
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
	var unexplored = get_parent() and not get_parent().explored
	visible = dice_number in [2,3,4,5,6,8,9,10,11,12] and not unexplored
	var frequency = 6-abs(dice_number-7)
	if not find_child('Number'): return
	if not dice_number: return
	if not frequency: return
	$Number.text = "{n}\n{dots}".format({
		"n": dice_number,
		"dots": '˙'.repeat(frequency)
	})
	$Number.label_settings = frequencyStyle.get(frequency)

func _draw():
	if dice_number not in [2,3,4,5,6,8,9,10,11,12]: return
	var last_trown = dice_number == 5
	draw_circle(Vector2.ZERO, 40, Color.DARK_GOLDENROD if last_trown else Color.BURLYWOOD )
	draw_circle(Vector2.ZERO, 36, Color.YELLOW if last_trown else Color.WHEAT)

func _ready():
	update_label()
