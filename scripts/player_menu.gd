extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape") and Globals.player.can_move:
		toggle_menu()
		
func toggle_menu():
	Globals.is_paused = !Globals.is_paused
	if Globals.is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Globals.player.can_move = false
		show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Globals.player.can_move = true
		hide()

func _on_resume_pressed() -> void:
	toggle_menu()

func _on_quit_pressed() -> void:
	Globals.return_to_menu()
