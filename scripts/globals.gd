extends Node

var peer: ENetMultiplayerPeer

@onready var player_scene = preload("res://scenes/player.tscn")

var current_scene: Node = null

func _ready():
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)

func host_server():
	peer = ENetMultiplayerPeer.new()
	
	var result = peer.create_server(99)
	
	if result != OK:
		printerr("Server Error: %s" % result)
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	
	goto_scene("res://scenes/main.tscn")
	
	_add_player.call_deferred()
	
func join_server(address):
	peer = ENetMultiplayerPeer.new()
	
	peer.create_client(address, 99)
	multiplayer.multiplayer_peer = peer
	
	goto_scene("res://scenes/main.tscn")

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	current_scene.add_child(player)

func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
	current_scene.free()

	var s = ResourceLoader.load(path)

	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
