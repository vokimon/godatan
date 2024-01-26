@icon("res://tiles/icon.png")
class_name Dice
extends RigidBody3D

@export var dice_color := Color.BROWN
@onready var original_position := position

const dice_size := 2.
const dice_density := 10.

var roll_time := 0.

signal roll_finished(int)

const sides = {
	1: Vector3.LEFT,
	2: Vector3.FORWARD,
	3: Vector3.DOWN,
	4: Vector3.UP,
	5: Vector3.BACK,
	6: Vector3.RIGHT,
}

func has_stabilized() -> bool:
	if global_position.y > dice_size: return false
	if linear_velocity.length() > dice_size: return false
	return true

func _init():
	continuous_cd = false
	can_sleep = true
	gravity_scale = 10
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	stop()

func _ready():
	print("Ready", can_sleep, can_process())
	original_position = position
	mass = dice_density * dice_size ** 3 
	$Collider.shape.size = dice_size * Vector3.ONE
	$Collider.shape.margin = dice_size * 0.1
	$DiceMesh.mesh.size = dice_size * Vector3.ONE
	$DiceMesh.material_override = $DiceMesh.material_override.duplicate()
	$DiceMesh.material_override.albedo_color = dice_color
	roll()

func stop():
	freeze = true
	sleeping = true
	position = 1. * Vector3(
		randf_range(-1.,+1.),
		5.0*dice_size,
		randf_range(-1.,+1.),
	)
	rotation = randf_range(0, 2*PI)*Vector3(1.,1.,1.)
	lock_rotation = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	print("Stopped: ", linear_velocity, " ", angular_velocity, " ", position)

func roll():
	stop()
	linear_velocity = 10*Vector3(-1,0, -1)
	angular_velocity = mass * 100. * 2 * PI * Vector3(1,0,1)
	freeze = false
	sleeping = false
	lock_rotation = false
	print("Pre impulse: ", linear_velocity, " ", angular_velocity, " ", position)
	#apply_central_impulse(mass * 10. * Vector3(randf_range(-1.,+1.), 0, randf_range(-1.,+1.)))
	#apply_torque_impulse( mass * 100. * 2 * PI * Vector3(1,0,1))
	roll_time = 0
	print("Impulsed: ", linear_velocity, " ", angular_velocity, " ", position)

func _process(_delta):
	roll_time += _delta
#	print("process ", roll_time)
	if roll_time < 1: return
	roll_time = 0
	if position.y < dice_size * .5:
		print("Penetration")
		apply_impulse(mass * Vector3(0, 1, 0), dice_size/2.*Vector3.ONE)
	
	if position.y > dice_size * .8:
		print("Arriba: ", position.y)
		return
	if linear_velocity.length() > dice_size * 0.1:
		print("Moviendose: ", linear_velocity)
		return
	if angular_velocity.length() > 1.:
		print("Rodando: ", angular_velocity)
		return
	var side = upper_side()
	if side:
		print("Side: ", side)
		print("Velocity: ", linear_velocity, " ", angular_velocity, " ", position)
		if linear_velocity.length() > 1.: return
		if angular_velocity.length() > 1.: return
		print("Dice {0} solved {1}".format([name, side]))
		freeze = true
		sleeping = true
		roll_finished.emit(side)
			

func upper_side() -> int:
	var unit_length := to_global(to_local(Vector3.UP).normalized()).length()
	var highest_y := -INF
	var highest_side := 0
	for side in sides:
		var y = to_global(sides[side]).y
		if y < highest_y: continue
		highest_y = y
		highest_side = side
	#print("{0} {1} {2}".format([highest_y, global_position.y, unit_length]))
	if highest_y - global_position.y > .9 * unit_length:
		return 0
	return highest_side

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			stop()
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			roll()
