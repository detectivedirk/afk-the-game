extends Control

@onready var username_scene = preload("res://scenes/util/username.tscn")

func _ready() -> void:
	Globals.player_connected.connect(_add_username)
	Globals.player_disconnected.connect(_remove_username)

func _process(_delta: float) -> void:
	for control in get_children():
		var user = Globals.current_scene.get_node("players/%s" % control.name)
		if !user: continue
		control.visible = not get_viewport().get_camera_3d().is_position_behind(user.global_position)
		control.position = get_viewport().get_camera_3d().unproject_position(user.global_position + \
		Vector3(0, 2, 0)) - \
		Vector2(control.get_content_width() * 0.5, 0)
		
func _add_username(id, _player_info):
	var control: RichTextLabel = username_scene.instantiate()
	add_child(control)
	control.text = Globals.players[id]["username"]
	control.size.x = control.get_content_width()
	control.name = str(id)

func _remove_username(id):
	get_node(str(id)).queue_free()
