extends Node

var chat_active = false

var current_tv = 0
var tv_enabled = true

signal enable_controls
signal chat(msg)

signal interact(up, who)

signal change_item(item, incr)
signal change_color(item, hue)

var in_space = false
signal go_to_space
signal die_in_space

func set_tv_enabled(on: bool) -> void:
	if on:
		JavaScriptBridge.eval("window.tv(true);", true)
	else:
		JavaScriptBridge.eval("window.tv(false);", true)
