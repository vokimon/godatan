## A Control holding an actionable Dice Roller
@icon("res://images/dice_roller_controller.svg")
extends SubViewportContainer
class_name DiceRollerControl

signal roll_finnished(int)

func roll():
	$SubViewport/DiceRoller.roll()

func _ready():
	$SubViewport/DiceRoller.roll_finnished.connect(
		func(value): roll_finnished.emit(value)
	)

func _process(_delta):
	pass
