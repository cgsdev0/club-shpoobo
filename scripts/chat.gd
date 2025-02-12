extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _process(delta):
	visible = Global.chat_active
	if has_focus() && !visible:
		release_focus()
	if !has_focus() && visible:
		grab_focus()

func _input(event):
	if event.is_action_pressed("chat_submit") && has_focus():
		hide()
		release_focus()
		var stripped = text.strip_edges()
		if stripped != "":
			Global.chat.emit(stripped)
			
		text = ""
		accept_event()
		Global.chat_active = false
		await get_tree().create_timer(0.1).timeout
		Global.enable_controls.emit()
