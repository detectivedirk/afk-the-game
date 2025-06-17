extends Control

@onready var panel = $panel

@onready var label_scene = preload("res://scenes/message.tscn")

func _ready() -> void:
	Globals.player_connected.connect(_add_player)
	Globals.player_disconnected.connect(_remove_player)
	
	Globals.data_updated.connect(_update_player)
	
func _add_player(id, info):
	var label = label_scene.instantiate()
	label.name = str(id)
	label.text = "%s : %s" % [info["username"], info["exp"]]
	panel.add_child(label)
	_update_board()
	
func _remove_player(id):
	var label = panel.get_node(str(id))
	label.queue_free()
	_update_board()

func _update_player(id, info):
	var label = panel.get_node(str(id))
	label.text = "%s : %s" % [info["username"], info["exp"]]

func _update_board():
	for i in range(panel.get_child_count()):
		var label = panel.get_child(i)
		label.position.y = i * 12
