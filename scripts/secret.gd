extends Sprite2D


@export var open = false

var was_open = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.timeout.connect(on_timer)
	pass # Replace with function body.

func on_timer():
	open = false
	
func interact(up, interactee):
	if !up && !open:
		open = true
	elif up && open && !is_instance_valid(tween):
		interactee.teleport($Marker2D.global_position)
	
var tween
func on_open():
	if multiplayer.is_server():
		$Timer.start(5.0)
	if is_instance_valid(tween):
		tween.kill()
	tween = get_tree().create_tween()
	var duration = inverse_lerp(80.0, 25.0, $HoleCover.position.y)
	print($HoleCover.position.y)
	print("duration ", duration)
	tween.tween_property($HoleCover, "position", Vector2($HoleCover.position.x, 80.0), 1.5 * duration)
	tween.tween_callback(func(): tween = null)

func on_close():
	$Timer.stop()
	if is_instance_valid(tween):
		tween.kill()
	tween = get_tree().create_tween()
	var duration = inverse_lerp(25.0, 80.0, $HoleCover.position.y)
	tween.tween_property($HoleCover, "position", Vector2($HoleCover.position.x, 25.0), 1.5 * duration)
	tween.tween_callback(func(): tween = null)
	
func _process(delta):
	if was_open != open:
		if open:
			on_open()
		else:
			on_close()
	was_open = open
