extends Node2D

var grid_position = Vector2.ZERO
var grid_size = Vector2.ZERO

@onready var parent = get_parent()
@onready var camera = get_viewport().get_camera_2d()

func _ready():
	# If you drag the camera from the OffsetPivot node,
	# its position will not be (0, 0)
	grid_size = Vector2(400, 32)
	set_as_top_level(true)
	update_grid_position()

var inertia = -1.0

func _process(delta):
	update_grid_position()
	var ab = abs(position.y - target_position.y)
	if ab < 10.0 || !parent.on_ground:
		inertia -= delta * 10.0
	else:
		inertia += delta * 16.0
	inertia = clampf(inertia, -1.0, 1.0)
	var diff = max(40, ab)
	position.y = move_toward(position.y, target_position.y, delta * diff * 5.0 * clampf(inertia, 0.0, 1.0))


func update_grid_position():
	var new_grid_position = calculate_grid_position()
	grid_position = new_grid_position
	jump_to_grid_position()


func calculate_grid_position():
	var x = round((parent.position.x - camera.offset.x / 2.0) / grid_size.x)
	var y = round((parent.position.y - 5 * camera.offset.y / 8.0) / grid_size.y)
	return Vector2(x, y)

var target_position = Vector2.ZERO
func jump_to_grid_position():
	target_position = Vector2(grid_position * grid_size)
	position.x = parent.position.x - camera.offset.x / 2.0
