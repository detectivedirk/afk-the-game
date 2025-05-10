extends Control

@onready var player_scene = preload("res://scenes/player.tscn")

@onready var address = $canvas/buttons/address

func _on_host_pressed() -> void:
	Globals.host_server()
	
func _on_join_pressed() -> void:
	if address.text != "":
		Globals.join_server(address.text)
	else:
		Globals.join_server("localhost")
