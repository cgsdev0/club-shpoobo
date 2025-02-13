extends Sprite2D


func _process(delta):
	var size = get_rect().size
	var pos = get_viewport().get_camera_2d().global_transform.affine_inverse() * (global_position - size - Vector2(40, 17))
	JavaScriptBridge.eval("window.x={0};window.y={1};window.sx={2};window.sy={3};window.cc();".format([pos.x, pos.y, size.x, size.y]), true)
