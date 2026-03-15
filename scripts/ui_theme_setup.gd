extends Node

## Sets up cyberpunk theme for all UI at runtime

const BG_COLOR := Color(0.05, 0.05, 0.1, 0.9)
const ACCENT_COLOR := Color(0.0, 1.0, 0.8)
const TEXT_COLOR := Color(0.8, 0.9, 1.0)
const BUTTON_BG := Color(0.08, 0.15, 0.2)
const BUTTON_HOVER := Color(0.1, 0.25, 0.3)
const BUTTON_PRESSED := Color(0.0, 0.4, 0.4)
const PANEL_BG := Color(0.03, 0.05, 0.08, 0.85)


static func apply_cyber_theme(root: Control) -> void:
	_style_recursive(root)


static func _style_recursive(node: Node) -> void:
	if node is Button:
		_style_button(node as Button)
	elif node is Label:
		_style_label(node as Label)
	elif node is ProgressBar:
		_style_progress_bar(node as ProgressBar)
	elif node is PanelContainer:
		_style_panel(node as PanelContainer)

	for child in node.get_children():
		_style_recursive(child)


static func _style_button(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = BUTTON_BG
	normal.border_color = ACCENT_COLOR
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(4)
	normal.set_content_margin_all(10)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = BUTTON_HOVER
	hover.border_color = ACCENT_COLOR
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(4)
	hover.set_content_margin_all(10)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = BUTTON_PRESSED
	pressed.border_color = Color(0.0, 1.0, 1.0)
	pressed.set_border_width_all(3)
	pressed.set_corner_radius_all(4)
	pressed.set_content_margin_all(10)
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color", ACCENT_COLOR)
	btn.add_theme_color_override("font_hover_color", Color(0.0, 1.0, 1.0))
	btn.add_theme_font_size_override("font_size", 22)


static func _style_label(lbl: Label) -> void:
	# Only override if no custom color set
	if not lbl.has_theme_color_override("font_color"):
		lbl.add_theme_color_override("font_color", TEXT_COLOR)


static func _style_progress_bar(bar: ProgressBar) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.05, 0.05, 0.1)
	bg.border_color = ACCENT_COLOR * 0.5
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", bg)

	var fill := StyleBoxFlat.new()
	fill.bg_color = ACCENT_COLOR * 0.8
	fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", fill)


static func _style_panel(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.border_color = ACCENT_COLOR * 0.3
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)
