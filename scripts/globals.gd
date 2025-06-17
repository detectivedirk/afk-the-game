extends Node

var peer: ENetMultiplayerPeer

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

signal afk_progress(progress)

signal reward_get

signal data_updated(id, info)

const PORT = 99
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

var players = {}
var player_info = {"username": "Player"}

@onready var player_scene = preload("res://scenes/player.tscn")

var current_scene: Node = null

var is_paused: bool = false

var chat: Node = null
var player: CharacterBody3D = null

var spawn_radius = 10

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(-1)
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	player_connected.connect(_add_player)
	player_disconnected.connect(_remove_player)
	
	data_updated.connect(_update_data)

func host_server(new_player_info):
	player_info = new_player_info
	
	peer = ENetMultiplayerPeer.new()
	
	var result = peer.create_server(99)
	
	if result != OK:
		printerr("Server Error: %s" % result)
		return
	
	multiplayer.multiplayer_peer = peer
	
	goto_scene("res://scenes/main.tscn")
	
	players[1] = new_player_info
	player_connected.emit.call_deferred(1, player_info)
	
func _update_data(id, info):
	players[id] = info
	
@rpc ("any_peer", "call_local")
func _global_update(id, info):
	data_updated.emit(id, info)
	
func join_server(new_player_info, address = ""):
	player_info = new_player_info
	
	peer = ENetMultiplayerPeer.new()
	
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var error = peer.create_client(address, 99)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	goto_scene("res://scenes/main.tscn")

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
	
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	if multiplayer.is_server():
		chat.server_message.rpc("%s joined the server" % new_player_info["username"])
	
func _on_player_disconnected(id):
	if multiplayer.is_server():
		chat.server_message.rpc("%s left the server" % players[id]["username"])
	players.erase(id)
	player_disconnected.emit(id)

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

func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
	current_scene.free()

	var s = ResourceLoader.load(path)

	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func _add_player(id, _new_player_info):
	var new_player = player_scene.instantiate()
	new_player.name = str(id)
	new_player.username = "Player"
	current_scene.get_node("players").add_child(new_player)
	
	spawn_player(new_player)
	
func spawn_player(object):
	object.position.x = randf_range(-spawn_radius, spawn_radius)
	object.position.z = randf_range(-spawn_radius, spawn_radius)
	
func _remove_player(id):
	var old_player = current_scene.get_node("players").get_node_or_null(str(id))
	if old_player:
		old_player.queue_free()
		
func reset_data():
	multiplayer.multiplayer_peer = null
	player = null
	chat = null
	player_info.clear()
	players.clear()

func return_to_menu():
	goto_scene("res://scenes/menu.tscn")
	reset_data.call_deferred()
