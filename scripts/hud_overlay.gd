extends CanvasLayer

func _ready():
	var draw = Control.new()
	draw.name = "HUDDraw"
	draw.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw.set_script(load("res://scripts/hud_draw.gd"))
	add_child(draw)
