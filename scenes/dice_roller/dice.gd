@icon("res://tiles/icon.png")
class_name Dice
extends RigidBody3D

@export var dice_color := Color.BROWN
@onready var original_position := position

const sides = {
	1: Vector3.LEFT,
	2: Vector3.FORWARD,
	3: Vector3.DOWN,
	4: Vector3.UP,
	5: Vector3.BACK,
	6: Vector3.RIGHT,
}
const dice_size := 2.
const dice_density := 10.
## The minimal angle between faces (different in a d20)
const face_angle := 90.
## how up must be a face unit vector for the face to be choosen
var max_tilt := cos(deg_to_rad(face_angle/float(sides.size())))

var roll_time := 0.
var n_shakes := 0
signal roll_finished(int)


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
	print(name, " ready, can_sleep ", can_sleep, " can_process ", can_process())
	original_position = position
	mass = dice_density * dice_size ** 3 
	$Collider.shape.size = dice_size * Vector3.ONE
	$Collider.shape.margin = dice_size * 0.1
	$DiceMesh.mesh.size = dice_size * Vector3.ONE
	$DiceMesh.material_override = $DiceMesh.material_override.duplicate()
	$DiceMesh.material_override.albedo_color = dice_color
	stop()

func stop():
	freeze = true
	sleeping = true
	position = original_position
	position.y = 5 * dice_size
	rotation = randf_range(0, 2*PI)*Vector3(1.,1.,1.)
	lock_rotation = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func roll():
	stop()
	linear_velocity = 10*Vector3(-1,0, -1)
	angular_velocity = mass * 100. * 2 * PI * Vector3(1,0,1)
	freeze = false
	sleeping = false
	lock_rotation = false
	roll_time = 0
	print("Pre impulse: ", linear_velocity, " ", angular_velocity, " ", position)
	apply_central_impulse(mass * 10. * Vector3(randf_range(-1.,+1.), 0, randf_range(-1.,+1.)))
	apply_torque_impulse( mass * 100. * 2 * PI * Vector3(1,0,1))
	print("Impulsed: ", linear_velocity, " ", angular_velocity, " ", position)

func shake(reason: String):
	"""Move a bad rolled dice"""
	print("Dice {0}: Reshaking {1}".format([name, reason]))
	apply_impulse(
		mass * 10. * Vector3(0,1,0),
		dice_size * Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)),
	)

func _process(_delta):
	roll_time += _delta
	if freeze: return
#	print("process ", roll_time)
	if roll_time < 1: return
	roll_time = 0
	if position.y < dice_size * .5:
		print("Dice {0}: Pushing up a bellow ground dice".format([name]))
		apply_impulse(mass * Vector3(0, 1, 0), dice_size/2.*Vector3.ONE)
	
	if linear_velocity.length() > dice_size * 0.1:
		#print("Still moving: ", linear_velocity)
		return
	if angular_velocity.length() > 1.:
		#print("Still rolling: ", angular_velocity)
		return
	if position.y > dice_size * .8:
		return shake("mounted")
	var side = upper_side()
	if not side:
		return shake("tilted")
	print("Dice {0} solved {1}".format([name, side]))
	freeze = true
	sleeping = true
	roll_finished.emit(side)

func upper_side() -> int:
	var highest_y := -INF
	var highest_side := 0
	for side in sides:
		var y = to_global(sides[side]).y
		if y < highest_y: continue
		highest_y = y
		highest_side = side
	print("{3} Face {0} from center {1} against unit {2}".format([
		highest_y, highest_y - global_position.y, max_tilt, name
	]))
	if highest_y - global_position.y < max_tilt:
		return 0
	return highest_side

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			stop()
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			roll()
