class_name DebugLabel
extends Label

var debug_lines: Array = []

func write(value: Variant):
	debug_lines.push_back(str(value))

func _process(_delta):
	text = "\n".join(debug_lines)
	debug_lines.clear()
