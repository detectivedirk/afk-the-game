extends Node3D

var peer = ENetMultiplayerPeer.new()

@onready var player_scene = preload("res://scenes/player.tscn")

@onready var buttons = $canvas/buttons
@onready var address = $canvas/buttons/address

func _on_host_pressed() -> void:
	peer.create_server(99)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	buttons.hide()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	
func _on_join_pressed() -> void:
	if address.text != "":
		peer.create_client(address.text, 99)
		multiplayer.multiplayer_peer = peer
		buttons.hide()
