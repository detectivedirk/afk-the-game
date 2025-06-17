extends Control

@onready var player_scene = preload("res://scenes/player.tscn")

@onready var username = $canvas/buttons/username
@onready var address = $canvas/buttons/address

func _on_host_pressed() -> void:
	if username.text == "": return
	Globals.host_server(_init_player())
	
func _on_join_pressed() -> void:
	if username.text == "": return
	Globals.join_server(_init_player(), address.text)
	
func _init_player() -> Dictionary:
	return {
		"username" : username.text, 
		"exp" : 0,
		"coins" : 0,
		"rank" : Values.Rank.NOOB
	}

func _on_quit_pressed() -> void:
	get_tree().quit()
