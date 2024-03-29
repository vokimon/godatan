extends RigidBody2D

const Terrain = Globals.Terrain

@export var terrain: Terrain = Terrain.Unknown
@export var dice_value: int:
	set(value):
		dice_value = value
		update_texture()

@export var explored: bool = false:
	get:
		return explored
	set(value):
		explored = value
		update_texture()

func event_processed():
	get_tree().get_root().set_input_as_handled()

func terrain_texture(_terrain):
	return Globals.terrain_texture(_terrain)

func on_dice_rolled(value):
	$DiceNumber.highlighted = explored and value == dice_value

func highlight_number():
	$DiceNumber.highlighted = not $DiceNumber.highlighted

func highlight_body():
	$Picture.color.a = .9

func unhighlight_body():
	$Picture.color.a = 1.

func _ready():
	update_texture()

func update_texture():
	if has_node("Picture"):
		$Picture.texture = terrain_texture(terrain if explored else Terrain.Unknown)
		$Picture.texture_offset = Vector2(randi_range(0,200), randi_range(0,200))
	if has_node("DiceNumber"):
		$DiceNumber.dice_number = dice_value if explored else 0
	if has_node("Border"):
		$Border.visible = terrain != Terrain.Sea and explored

func flip():
	$Animator.play("flipout")

func flip_apply():
	explored = not explored
	update_texture()

func _on_input_event(_viewport, event, _shape_idx):
	# TODO: Debug only
	if event is InputEventMouseButton:
		if event.is_released():
			match event.button_index:
				MOUSE_BUTTON_LEFT: flip()
				MOUSE_BUTTON_RIGHT: highlight_number()
				_: return
			event_processed()

func _on_mouse_entered():
	highlight_body()

func _on_mouse_exited():
	unhighlight_body()
