extends Control

## Main Menu for CYBERDIVER

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var start_button: Button = $VBoxContainer/ButtonContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/ButtonContainer/QuitButton
@onready var version_label: Label = $VersionLabel
@onready var particles: GPUParticles2D = $BackgroundParticles


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Apply cyber theme
	var theme_setup := load("res://scripts/ui_theme_setup.gd")
	if theme_setup:
		theme_setup.apply_cyber_theme(self)

	# Style title
	if title_label:
		title_label.add_theme_font_size_override("font_size", 72)
		title_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.8))
	if subtitle_label:
		subtitle_label.add_theme_font_size_override("font_size", 24)
		subtitle_label.add_theme_color_override("font_color", Color(0.4, 0.7, 0.8))
	if version_label:
		version_label.add_theme_font_size_override("font_size", 14)
		version_label.add_theme_color_override("font_color", Color(0.3, 0.5, 0.6))

	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Animate title
	if title_label:
		var tween := create_tween()
		title_label.modulate.a = 0.0
		tween.tween_property(title_label, "modulate:a", 1.0, 1.5)

	if subtitle_label:
		var tween2 := create_tween()
		subtitle_label.modulate.a = 0.0
		tween2.tween_interval(0.5)
		tween2.tween_property(subtitle_label, "modulate:a", 1.0, 1.0)


func _on_start_pressed() -> void:
	GameManager.go_to_briefing()


func _on_quit_pressed() -> void:
	get_tree().quit()
