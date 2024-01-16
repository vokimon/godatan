extends RigidBody2D
const Globals = preload("res://Globals.gd")

const Terrain = Globals.Terrain
@export var terrain: Terrain = Terrain.Unknown
@export var dice_value: int:
	set(value):
		dice_value = value
		$DiceNumber.dice_number = value

var _explored: bool = false
@export var explored: bool:
	get:
		return _explored
	set(value):
		_explored = value
		update_texture()

func terrain_texture(terrain):
	return Globals.terrain_texture(terrain)

func reveal():
	explored = true
	$Picture.texture = terrain_texture(terrain)

func highlight_body():
	$Border.visible = true

func unhighlight_body():
	$Border.visible = false

func _ready():
	update_texture()

func update_texture():
	$Picture.texture = terrain_texture(terrain if explored else Terrain.Unknown)
	$Picture.texture_offset = Vector2(randi_range(0,200), randi_range(0,200))
	
func _process(delta):
	#$Picture.texture_offset = Vector2.ONE*((int(Time.get_ticks_msec())>>6)&127)
	pass


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		#print("event ", event)
		if event.is_released():
			explored = not explored
			update_texture()

func _on_mouse_entered():
	highlight_body()

func _on_mouse_exited():
	unhighlight_body()
