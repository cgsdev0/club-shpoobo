extends Sprite2D

@export var tv_id = 0

func _process(delta):
	if Global.current_tv != tv_id:
		return
	var size = get_rect().size
	var pos = get_viewport().get_camera_2d().global_transform.affine_inverse() * (global_position - size - Vector2(40, 17))
	JavaScriptBridge.eval("window.x={0};window.y={1};window.sx={2};window.sy={3};window.cc();".format([pos.x, pos.y, size.x, size.y]), true)
