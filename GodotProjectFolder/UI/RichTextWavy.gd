extends RichTextEffect
class_name RichTextWavy


# Syntax: [wavy amp=5.0 len=10.0 rate=5.0][/wavy]

# Define the tag name.
var bbcode = "wavy"


func _process_custom_fx(char_fx):
	# Get parameters, or use the provided default value if missing.
	var amp = char_fx.env.get("amp", 2.0)
	var freq = char_fx.env.get("freq", 10.0)
	var rate = char_fx.env.get("rate", 10.0)
	
	var y_wave = sin((char_fx.elapsed_time + (char_fx.range.x * freq)) * rate)
	char_fx.offset = Vector2.DOWN * y_wave * amp
	return true
