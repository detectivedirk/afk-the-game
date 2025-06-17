extends Node3D

class_name Game

var coin_scene = preload("res://scenes/coin.tscn")

@onready var coins = $coins
@onready var afk_timer : Timer = $logic/afk_timer

var coin_spawn_radius = 15
var coin_spawn_interval = 10

func _ready():
	spawn_coin.rpc()
	afk_timer.timeout.connect(afk_next)
	
func _process(_delta: float) -> void:
	process_afk()
	
func process_afk():
	var progress = 1 - afk_timer.time_left / afk_timer.wait_time
	Globals.afk_progress.emit(progress)
	
func afk_next():
	var id = Globals.player.name.to_int()
	var info = Globals.players[id]
	
	info["exp"] += 1
	Globals.data_updated.emit(id, info)
	
	Globals.player.celebration()

@rpc("any_peer", "call_local")
func spawn_coin():
	await get_tree().create_timer(coin_spawn_interval).timeout
	var coin = coin_scene.instantiate()
	coins.add_child(coin)
	coin.position.x = randf_range(-coin_spawn_radius, coin_spawn_radius)
	coin.position.z = randf_range(-coin_spawn_radius, coin_spawn_radius)
	coin.position.y = 0.5
	spawn_coin.rpc()
