extends Area3D

func _ready() -> void:
	$player.play("spin")

func _on_body_entered(body: Node) -> void:
	print("%s collided" % body)
	if body.is_in_group("player"):
		if body.name in ["head", "torso"]:
			body = body.get_parent().get_parent()
	body.collect_coin()
	queue_free()
