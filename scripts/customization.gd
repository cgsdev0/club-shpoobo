extends MarginContainer


func _ready():
	visible = false
	


func _input(event):
	if event.is_action_pressed("customize") && !Global.chat_active:
		visible = !visible


func _on_body_color_value_changed(value):
	Global.change_color.emit(1, "body", value)


func _on_hat_color_value_changed(value):
	Global.change_color.emit(1, "hat", value)


func _on_prev_hat_pressed():
	Global.change_item.emit(1, "hat", -1)


func _on_next_hat_pressed():
	Global.change_item.emit(1, "hat", 1)


func _on_prev_body_pressed():
	Global.change_item.emit(1, "body", -1)


func _on_next_body_pressed():
	Global.change_item.emit(1, "body", 1)
