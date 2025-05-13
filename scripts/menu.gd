extends Control

@onready var player_scene = preload("res://scenes/player.tscn")

@onready var username = $canvas/buttons/username
@onready var address = $canvas/buttons/address

func _on_host_pressed() -> void:
	if username.text == "": return
	Globals.host_server({"username" : username.text})
	
func _on_join_pressed() -> void:
	if username.text == "": return
	Globals.join_server({"username" : username.text}, address.text)
