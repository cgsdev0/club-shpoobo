extends Node

var chat_active = false

var current_tv = 0

signal enable_controls
signal chat(msg)

signal interact(up, who)

signal change_item(item, incr)
signal change_color(item, hue)

var in_space = false
signal go_to_space
signal die_in_space
