extends Control

@onready var messages = $panel/messages
@onready var input = $input

@onready var message = preload("res://scenes/message.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("chat"):
		input.grab_focus()

func _on_input_text_submitted(new_text: String) -> void:
	rpc("msg_rpc", new_text)
	input.text = ""
	input.release_focus()
	
@rpc ("any_peer", "call_local")
func msg_rpc(data):
	var new_message: RichTextLabel = message.instantiate()
	new_message.text = data
	messages.call_deferred("add_child", new_message)
	
	new_message.position.y = (messages.get_child_count() - 1) * 24
	
	messages.position.y = 140 - messages.get_child_count() * 24

	
