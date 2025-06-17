@tool
extends RichTextEffect
class_name RichTextWave

var bbcode = "weave"

func _process_custom_fx(char_fx):
	var amp = char_fx.env.get("amp", 2)
	var dist = char_fx.env.get("dist", 10)
	var speed = char_fx.env.get("speed", 10)

	var offset = sin(char_fx.elapsed_time * speed + char_fx.transform.get_origin().x * dist) * amp
	char_fx.offset = Vector2(0, offset)
	
	return true
