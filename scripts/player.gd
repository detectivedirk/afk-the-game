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

var dead: bool = false

@onready var jump_velocity : float = ((2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK) * 1.0
@onready var jump_gravity : float = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_PEAK * JUMP_TIME_TO_PEAK)) * 1.0
@onready var fall_gravity : float = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_DESCENT * JUMP_TIME_TO_DESCENT)) * 1.0

@onready var camera = $camera_stand
@onready var model = $model
@onready var collider = $collider

@onready var sfxplayer = $sfx_player
@onready var listener = $listener

@onready var head: RigidBody3D = $model/head
@onready var torso: RigidBody3D = $model/torso

var firework = preload("res://scenes/particles/firework.tscn")

var username = "User"

var camera_distance: float = 1

var can_move = true

var game: Game

func get_jump_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	game = Globals.current_scene
	if is_multiplayer_authority():
		listener.make_current()
		camera.get_child(0).make_current()
		Globals.player = self
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority() and not dead:
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
	
	if (movement_vector != Vector2.ZERO or Input.is_action_just_released("jump")) and not dead and can_move:
		dead = true
		await get_tree().create_timer(0.1).timeout
		death()

func reset():
	head.position = Vector3(0, 1.35, 0)
	head.rotation = Vector3.ZERO
	
	torso.position = Vector3(0, 0.5, 0)
	torso.rotation = Vector3.ZERO

func death():
	can_move = false
	
	head.freeze = false
	torso.freeze = false
	
	head.apply_impulse(Vector3(randf_range(-1, 1), randf_range(0, 2), randf_range(-1, 1)) * 5)
	torso.apply_impulse(Vector3(randf_range(-1, 1), randf_range(0, 2), randf_range(-1, 1)) * 3)
	
	collider.disabled = true
	head.get_node("shape").disabled = false
	torso.get_node("shape").disabled = false
	
	game.afk_timer.stop()
	
	Globals.chat.server_message.rpc("%s met their demise" % Globals.players[int(name)]["username"], "red")
	play_death_animation()
	
	await get_tree().create_timer(2).timeout
	Globals.spawn_player(self)
	
	head.get_node("shape").disabled = true
	torso.get_node("shape").disabled = true
	collider.disabled = false
	
	reset()
	game.afk_timer.start()
	
	head.freeze = true
	torso.freeze = true
	
	can_move = true
	
	dead = false
	
func collect_coin():
	var id = multiplayer.get_unique_id()
	var info = Globals.players[id]
	info["coins"] += 1
	
	Globals.data_updated.emit(id, info)
	
	sfxplayer.play_sound_multiplayer.rpc("coin")

func play_death_animation():
	sfxplayer.play_sound_multiplayer.rpc("rampage")
	
func launch_firework():
	var particle: GPUParticles3D = firework.instantiate()
	add_child(particle)
	particle.emitting = true
	await get_tree().create_timer(2).timeout
	particle.queue_free()

func celebration():
	sfxplayer.play_sound_multiplayer.rpc("firework")
	for i in range(3):
		sfxplayer.play_sound_multiplayer("bonus2")
		launch_firework()
		Globals.reward_get.emit()
		await get_tree().create_timer(0.225).timeout
