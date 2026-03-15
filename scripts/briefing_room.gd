extends Control

## Briefing Room - Pre-battle gate selection and timer

@onready var timer_label: Label = $VBoxContainer/TimerLabel
@onready var gate_container: HBoxContainer = $VBoxContainer/GateContainer
@onready var team_label: Label = $VBoxContainer/TeamLabel
@onready var info_label: Label = $VBoxContainer/InfoLabel
@onready var start_button: Button = $VBoxContainer/StartButton

var selected_gate: String = "A"
var gate_buttons: Array[Button] = []


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Apply cyber theme
	var theme_setup := load("res://scripts/ui_theme_setup.gd")
	if theme_setup:
		theme_setup.apply_cyber_theme(self)

	if timer_label:
		timer_label.add_theme_font_size_override("font_size", 36)
		timer_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.8))
	if team_label:
		team_label.add_theme_font_size_override("font_size", 28)
		team_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	if info_label:
		info_label.add_theme_font_size_override("font_size", 18)

	GameManager.change_state(GameManager.GameState.BRIEFING)
	GameManager.briefing_timer_updated.connect(_on_timer_updated)

	if team_label:
		team_label.text = "TEAM ALPHA"

	_create_gate_buttons()

	if start_button:
		start_button.pressed.connect(_on_start_pressed)

	if info_label:
		info_label.text = "Select your spawn gate and prepare for battle!\nBattle starts when timer reaches 0, or press START."


func _create_gate_buttons() -> void:
	if not gate_container:
		return

	var gates := ["A", "B", "C", "D", "E"]
	for gate_name in gates:
		var btn := Button.new()
		btn.text = "GATE %s" % gate_name
		btn.custom_minimum_size = Vector2(120, 60)
		btn.pressed.connect(_on_gate_selected.bind(gate_name))

		# Style
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.3, 0.4)
		style.border_color = Color(0.0, 0.8, 0.8)
		style.set_border_width_all(2)
		style.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal", style)

		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color(0.1, 0.4, 0.5)
		hover_style.border_color = Color(0.0, 1.0, 1.0)
		hover_style.set_border_width_all(2)
		hover_style.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("hover", hover_style)

		btn.add_theme_color_override("font_color", Color(0.0, 1.0, 0.9))
		btn.add_theme_font_size_override("font_size", 20)

		gate_container.add_child(btn)
		gate_buttons.append(btn)

	# Select first by default
	_on_gate_selected("A")


func _on_gate_selected(gate_name: String) -> void:
	selected_gate = gate_name
	GameManager.selected_gate = gate_name

	# Update button visuals
	for i in range(gate_buttons.size()):
		var btn: Button = gate_buttons[i]
		var gates := ["A", "B", "C", "D", "E"]
		if gates[i] == gate_name:
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.0, 0.6, 0.6)
			style.border_color = Color(0.0, 1.0, 1.0)
			style.set_border_width_all(3)
			style.set_corner_radius_all(4)
			btn.add_theme_stylebox_override("normal", style)
		else:
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.1, 0.3, 0.4)
			style.border_color = Color(0.0, 0.8, 0.8)
			style.set_border_width_all(2)
			style.set_corner_radius_all(4)
			btn.add_theme_stylebox_override("normal", style)


func _on_timer_updated(time_left: float) -> void:
	if timer_label:
		var seconds: int = int(time_left)
		timer_label.text = "BATTLE STARTS IN: %d" % seconds

	if time_left <= 0.0:
		_start_battle()


func _on_start_pressed() -> void:
	_start_battle()


func _start_battle() -> void:
	GameManager.is_briefing_active = false
	GameManager.go_to_battle()
