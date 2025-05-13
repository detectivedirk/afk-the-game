extends SpringArm3D

var sensibility: float = 0.005

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_released("wheel_down"):
		spring_length += 0.5
	if Input.is_action_just_released("wheel_up"):
		spring_length -= 0.5
	spring_length = clamp(spring_length, 1, 10)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_move_camera(event)
	
func _move_camera(event: InputEventMouseMotion):
	rotation.y -= event.relative.x * sensibility
	rotation.y = wrapf(rotation.y, 0.0, TAU)
	
	rotation.x -= event.relative.y * sensibility
	rotation.x = clamp(rotation.x, -PI/2, PI/4)
