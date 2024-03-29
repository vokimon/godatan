@icon("res://images/icon.png")
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
var rolling := false
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

func _ready():
	original_position = position
	mass = dice_density * dice_size ** 3 
	$Collider.shape.size = dice_size * Vector3.ONE
	$Collider.shape.margin = dice_size * 0.1
	$DiceMesh.mesh.size = dice_size * Vector3.ONE
	$DiceMesh.material_override = $DiceMesh.material_override.duplicate()
	$DiceMesh.material_override.albedo_color = dice_color
	stop()

func stop():
	$DiceMesh/Outline.visible = false
	freeze = true
	sleeping = true
	position = original_position
	position.y = 5 * dice_size
	rotation = randf_range(0, 2*PI)*Vector3(1.,1.,1.)
	lock_rotation = true # TODO: should not be set?
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func roll():
	if position.y < dice_size*2: stop()
	linear_velocity = Vector3(-1,0, -1)
	angular_velocity = Vector3.ZERO
	freeze = false
	sleeping = false
	lock_rotation = false
	roll_time = 0
	rolling = true
	apply_torque_impulse( dice_size * mass * TAU * Vector3(
		randf_range(-1.,+1.), 0, randf_range(-1.,+1.)
	))

func shake(reason: String):
	"""Move a bad rolled dice"""
	print("Dice {0}: Reshaking {1}".format([name, reason]))
	apply_impulse(
		mass * 10. * Vector3(0,1,0),
		dice_size * Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)),
	)

func _process(_delta):
	if not rolling: return
	roll_time += _delta
	#if position.y < dice_size * .5:
		#print("Dice {0}: Bellow ground, pushing up".format([name]))
		#apply_impulse(mass * Vector3(0, 1, 0), dice_size/2.*Vector3.ONE)
		#position.y = dice_size * .5

	if linear_velocity.length() > dice_size * 0.2:
		#print("Still moving: ", linear_velocity)
		return
	if angular_velocity.length() > 10.:
		#print("Still rolling: ", angular_velocity)
		return
	if position.y > dice_size * .8:
		return shake("mounted")
	var side = upper_side()
	if not side:
		return shake("tilted")
	print("Dice %s solved [%s] - %.02fs"%([name, side, roll_time]))
	freeze = true
	sleeping = true
	rolling = false
	roll_finished.emit(side)
	$DiceMesh/Outline.visible = true
	position.y+=.2 # avoids outline to intersect floor

func upper_side() -> int:
	var highest_y := -INF
	var highest_side := 0
	for side in sides:
		var y = to_global(sides[side]).y
		if y < highest_y: continue
		highest_y = y
		highest_side = side
	#print("{3} Face {0} from center {1} against threshold {2}".format([
	#	highest_y, highest_y - global_position.y, max_tilt, name
	#]))
	if highest_y - global_position.y < max_tilt:
		return 0
	return highest_side

func show_face(value):
	"""Shows a given face by rotating it up"""
	if value not in sides: return
	var face_normal = (to_global(sides[value])-global_position).normalized()
	print(name, " face normal ", face_normal, " ", value)
	var cross = face_normal.cross(Vector3.UP).normalized()
	var angle = face_normal.angle_to(Vector3.UP)
	print(name, " ", cross, " ", angle)
	#create_tween().tween_property(self, "rotation", 2, 5)
	rotate(cross, angle)
	
