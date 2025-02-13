extends Node

const PORT = 5451
const MAX_CLIENTS = 1000

var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}

var players_loaded = 0

var player_scene = preload("res://scenes/shpoobo.tscn")

@onready var spawner = $MultiplayerSpawner

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	if new_player_id == 1:
		return
	if !multiplayer.is_server():
		players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	
# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
	if multiplayer.is_server():
		var pc = player_scene.instantiate()
		pc.name = str(id)
		$Players.add_child(pc, true)
		players[id] = pc
		
func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	if multiplayer.is_server():
		for child in $Players.get_children():
			if child.name == str(id):
				child.queue_free()

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

func on_interact(up, who):
	var space_state = get_viewport().get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	var interactee = players[who]
	if !is_instance_valid(interactee):
		return
	query.position = interactee.global_position
	query.collision_mask = 4 # layer 3
	query.collide_with_areas = true  # Ensure we're checking against areas, not just physics bodies
	var result = space_state.intersect_point(query)
	if result.size() > 0:
		result[0].collider.get_parent().interact(up, interactee)
	
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	Global.interact.connect(on_interact)
	if OS.has_feature("dedicated_server"):
		start_server()
	else:
		start_client()
		
func start_server():
	# Create server.
	
		var peer = WebSocketMultiplayerPeer.new()
		var error = peer.create_server(PORT)
		if error:
			return error
		multiplayer.multiplayer_peer = peer
		print("booting as server")

func start_client():
		# await get_tree().create_timer([1.0, 10.0].pick_random()).timeout
		# Create client.
		var peer = WebSocketMultiplayerPeer.new()
		var error = peer.create_client("ws://127.0.0.1:5451")
		if error:
			return error
		print("connecting as client...")
		multiplayer.multiplayer_peer = peer
		
func _process(delta):
	%DebugInfo.text = str(players).replace(", ", ",\n  ")
	%OnlineCount.text = "[right]" + str(players.size()) + " player(s) online  "
