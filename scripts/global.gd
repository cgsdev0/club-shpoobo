extends Node

var chat_active = false

signal enable_controls
signal chat(msg)

signal interact(up, who)

signal change_item(peer_id, item, incr)
signal change_color(peer_id, item, hue)
