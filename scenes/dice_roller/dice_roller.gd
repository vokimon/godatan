extends Node3D
class_name DiceRoller
const DiceScene = preload("./dice.tscn")

@export var dice_definitions = {
	'red': {
		'color': Color.FIREBRICK,
	},
	'yellow': {
		'color': Color.GOLDENROD,
	},
}
var dices := []
var result := {}
var rolling := false

signal roll_finnished(value: int)

var total_value:=0 :
	get:
		var total := 0
		for dice_name in result:
			total += result[dice_name]
		return total

func roll():
	result = {}
	rolling = true
	for dice in dices:
		dice.roll()

func prepare():
	for dice in dices:
		dice.stop()

func _ready():
	const launch_height := Dice.dice_size * 5.
	var dice_x := -(dice_definitions.size()-1)/2.
	for dice_name: String in dice_definitions:
		var dice = DiceScene.instantiate()
		dice.name = dice_name
		dice.dice_color = dice_definitions[dice_name].color
		dice.position = Vector3(dice_x*Dice.dice_size*1.3, launch_height, 0.)
		dice_x += 1
		dice.roll_finished.connect(_on_finnished_dice_rolling.bind(dice_name))
		add_child(dice)
		dices.append(dice)

func _on_finnished_dice_rolling(number: int, dice_name: String):
	#print("Roller received dice done ", dice_name, " with ", number)
	result[dice_name] = number
	if result.size() == dices.size():
		rolling = false
		print("======= ", result, " -> ", total_value)
		roll_finnished.emit(total_value)
		# TODO: Once the strucutre is more set, connect it better
		var board = get_tree().root.get_node("Board")
		board and board.dice_rolled(total_value)

func _input(event: InputEvent) -> void:
	if rolling: return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			prepare()
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			roll()
