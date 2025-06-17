extends AudioStreamPlayer

var muted = false

func _on_finished() -> void:
	play()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_M:
			muted = !muted
			if !muted: 
				volume_db = -20
			else:
				volume_linear = 0
