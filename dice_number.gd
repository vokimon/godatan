extends Node2D
@export var dice_number: int = 0:
	set(value):
		dice_number = value
		update_label()

static var WhiteNumber = preload("res://label_settings_dice_number_normal.tres")
static var RedNumber = preload("res://label_settings_dice_numbers_red.tres")

func update_label():
	var unexplored = get_parent() and not get_parent().explored
	visible = dice_number in [2,3,4,5,6,8,9,10,11,12] and not unexplored
	if not $Number: return
	$Number.text = "{n}\n{dots}".format({
		"n":dice_number,
		"dots": '˙'.repeat(6-abs(dice_number-7))
	})
	$Number.label_settings = RedNumber if dice_number in [6,8] else WhiteNumber

func _draw():
	if dice_number not in [2,3,4,5,6,8,9,10,11,12]: return
	var last_trown = dice_number == 5
	draw_circle(Vector2.ZERO, 40, Color.DARK_GOLDENROD if last_trown else Color.BURLYWOOD )
	draw_circle(Vector2.ZERO, 36, Color.YELLOW if last_trown else Color.WHEAT)

# Called when the node enters the scene tree for the first time.
func _ready():
	#$Number.label_settings.lines_skipping=1
	update_label()
	return
