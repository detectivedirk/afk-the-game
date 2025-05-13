extends CharacterBody3D

const COYOTE_TIME = 0.15
const BUFFER_TIME = 0.15

var speed = 10.0

var speed_boost = 1

const JUMP_HEIGHT = 3
const JUMP_TIME_TO_PEAK = 0.35
const JUMP_TIME_TO_DESCENT = 0.25

const TERMINAL_VELOCITY = 300

var coyote_timer: float = 0
var buffer_timer: float = 0

@onready var jump_velocity : float = ((2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK) * 1.0
@onready var jump_gravity : float = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_PEAK * JUMP_TIME_TO_PEAK)) * 1.0
@onready var fall_gravity : float = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_DESCENT * JUMP_TIME_TO_DESCENT)) * 1.0

@onready var camera = $camera_stand
@onready var model = $model

var username = "User"

var camera_distance: float = 1

var can_move = true
	
func get_jump_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		camera.get_child(0).make_current()
		Globals.player = self
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_move_player(delta)
	
func _move_player(delta: float):
	var movement_vector = Vector2.ZERO
	
	if can_move:
		if Input.is_action_pressed("forward"):
			movement_vector += Vector2.UP
		if Input.is_action_pressed("left"):
			movement_vector += Vector2.LEFT
		if Input.is_action_pressed("back"):
			movement_vector += Vector2.DOWN
		if Input.is_action_pressed("right"):
			movement_vector += Vector2.RIGHT
		
	movement_vector = movement_vector.rotated(-camera.rotation.y) * speed	
	
	velocity.x = movement_vector.x
	velocity.z = movement_vector.y
	
	if movement_vector != Vector2.ZERO:
		model.rotation.y = camera.rotation.y + PI
	
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
		velocity.y += get_jump_gravity() * delta

	buffer_timer -= delta
	if Input.is_action_just_pressed("jump") and can_move:
		buffer_timer = BUFFER_TIME
		
	if buffer_timer > 0 and coyote_timer > 0:
		buffer_timer = 0
		coyote_timer = 0
		velocity.y = jump_velocity
	
	if Input.is_action_just_released("jump") && velocity.y > 0:
		velocity.y = 0
	
	move_and_slide()
