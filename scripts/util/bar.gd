extends NinePatchRect

@onready var bar = $progress

var reward = preload("res://scenes/particles/reward.tscn")

func _init() -> void:
	Globals.afk_progress.connect(_update_bar)
	Globals.reward_get.connect(_spawn_particle)
	
func _update_bar(progress):
	bar.size.x = progress * size.x

func _spawn_particle():
	var particle = reward.instantiate()
	add_child(particle)
	particle.position = Vector2(145, -60)
	particle.get_node("anim").play("afk_popup")
