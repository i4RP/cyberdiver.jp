extends Control

## Draws a crosshair in the center of the screen

const CROSSHAIR_SIZE: float = 12.0
const CROSSHAIR_GAP: float = 4.0
const CROSSHAIR_THICKNESS: float = 2.0
const CROSSHAIR_COLOR: Color = Color(0.0, 1.0, 0.8, 0.9)


func _draw() -> void:
	var center := size / 2.0

	# Top line
	draw_line(
		Vector2(center.x, center.y - CROSSHAIR_GAP),
		Vector2(center.x, center.y - CROSSHAIR_GAP - CROSSHAIR_SIZE),
		CROSSHAIR_COLOR, CROSSHAIR_THICKNESS
	)
	# Bottom line
	draw_line(
		Vector2(center.x, center.y + CROSSHAIR_GAP),
		Vector2(center.x, center.y + CROSSHAIR_GAP + CROSSHAIR_SIZE),
		CROSSHAIR_COLOR, CROSSHAIR_THICKNESS
	)
	# Left line
	draw_line(
		Vector2(center.x - CROSSHAIR_GAP, center.y),
		Vector2(center.x - CROSSHAIR_GAP - CROSSHAIR_SIZE, center.y),
		CROSSHAIR_COLOR, CROSSHAIR_THICKNESS
	)
	# Right line
	draw_line(
		Vector2(center.x + CROSSHAIR_GAP, center.y),
		Vector2(center.x + CROSSHAIR_GAP + CROSSHAIR_SIZE, center.y),
		CROSSHAIR_COLOR, CROSSHAIR_THICKNESS
	)

	# Center dot
	draw_circle(center, 1.5, CROSSHAIR_COLOR)
