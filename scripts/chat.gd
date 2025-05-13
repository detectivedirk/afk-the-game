extends Control

@onready var messages = $panel/messages
@onready var input = $input

@onready var message = preload("res://scenes/message.tscn")

func _init() -> void:
	Globals.chat = self

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("chat"):
		input.grab_focus()
		Globals.player.can_move = false

func _on_input_text_submitted(new_text: String) -> void:
	chat_message.rpc("%s: %s" % [Globals.player_info["username"], new_text.c_escape()])
	input.text = ""
	input.release_focus()
	Globals.player.can_move = true
	
@rpc ("any_peer", "call_local")
func chat_message(data):
	var new_message: RichTextLabel = message.instantiate()
	new_message.text = data
	messages.add_child.call_deferred(new_message)
	
	new_message.position.y = (messages.get_child_count() - 1) * 12
	
	messages.position.y = 74 - messages.get_child_count() * 12
	update_chat()

@rpc ("any_peer", "call_local")
func server_message(data, color = "yellow"):
	var new_message: RichTextLabel = message.instantiate()
	new_message.text = "[color=%s]%s[/color]" % [color, data]
	messages.add_child.call_deferred(new_message)
	
	new_message.position.y = (messages.get_child_count() - 1) * 12
	update_chat()
	
func update_chat():
	messages.position.y = 74 - messages.get_child_count() * 12
