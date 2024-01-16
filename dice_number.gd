extends Node2D
@export var dice_number: int = 0:
	set(value):
		dice_number = value
		visible = value in [2,3,4,5,6,8,9,10,11,12]
		update_label()
		
func update_label():
	if not $Number: return
	$Number.text = "{n}".format({"n":dice_number})
	$Dots.text = "{dots}".format({
		'dots':
			'.' if dice_number in [2,12] else
			'..' if dice_number in [3,4,11,10] else
			'...' if dice_number in [5,9] else
			'....',
	})
	#$Label.theme_override_colors.font_color = Color.RED if dice_number in [6,8] else Color.WHITE
	var color = Color.RED if dice_number in [6,8] else Color.WHITE
	$Number.set('theme_override_colors/font_color', color)
	$Dots.set('theme_override_colors/font_color', color)

func _draw():
	if dice_number not in [2,3,4,5,6,8,9,10,11,12]: return
	draw_circle(Vector2.ZERO, 40, Color.WHEAT)

# Called when the node enters the scene tree for the first time.
func _ready():
	update_label()
	return
