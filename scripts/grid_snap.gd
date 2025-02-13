extends Node2D

@onready var parent = get_parent()
@onready var camera = get_viewport().get_camera_2d()

var target_position = Vector2(0.0, 200.0)
func _ready():
	set_as_top_level(true)


var was_locked = false
func _process(delta):
	if get_parent().locked:
		was_locked = true
		return

	var ty = get_parent().last_y - 128
	if was_locked:
		was_locked = false
		position.y = get_parent().global_position.y
	var ab = abs(position.y - ty)
	var diff = max(20, ab)
	position.y = move_toward(position.y, ty, delta * diff * 5.0)
	position.x = get_parent().global_position.x - camera.offset.x
