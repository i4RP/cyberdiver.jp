extends Control

## Results Screen - shows battle statistics and BP earned

@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var stats_container: VBoxContainer = $VBoxContainer/StatsContainer
@onready var bp_label: Label = $VBoxContainer/BPLabel
@onready var menu_button: Button = $VBoxContainer/MenuButton


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Apply cyber theme
	var theme_setup := load("res://scripts/ui_theme_setup.gd")
	if theme_setup:
		theme_setup.apply_cyber_theme(self)

	if result_label:
		result_label.add_theme_font_size_override("font_size", 56)
	if bp_label:
		bp_label.add_theme_font_size_override("font_size", 28)
		bp_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))

	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

	_display_results()


func _display_results() -> void:
	# Win/Loss
	if result_label:
		if BattleData.battle_won:
			result_label.text = "VICTORY"
			result_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.5))
			if BattleData.perfect_victory:
				result_label.text = "PERFECT VICTORY"
		else:
			result_label.text = "DEFEAT"
			result_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))

	# Stats
	if stats_container:
		_add_stat("Kills", str(BattleData.kills))
		_add_stat("Deaths", str(BattleData.deaths))
		_add_stat("Damage Dealt", str(int(BattleData.damage_dealt)))
		_add_stat("Damage Taken", str(int(BattleData.damage_taken)))
		_add_stat("Cyber Souls Collected", str(BattleData.cyber_souls_collected))
		_add_stat("Cyber Souls Lost", str(BattleData.cyber_souls_lost))
		_add_stat("Respawns", str(BattleData.respawn_count))
		_add_stat("Team Life (Ally)", str(BattleData.final_team_life_ally))
		_add_stat("Team Life (Enemy)", str(BattleData.final_team_life_enemy))

	# BP
	var total_bp: int = BattleData.calculate_battle_points()
	if bp_label:
		bp_label.text = "BATTLE POINTS EARNED: %d BP" % total_bp

		# Animate BP counter
		var tween := create_tween()
		bp_label.modulate.a = 0.0
		tween.tween_property(bp_label, "modulate:a", 1.0, 1.0)


func _add_stat(stat_name: String, stat_value: String) -> void:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(500, 30)

	var name_label := Label.new()
	name_label.text = stat_name
	name_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.9))
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(name_label)

	var value_label := Label.new()
	value_label.text = stat_value
	value_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.9))
	value_label.add_theme_font_size_override("font_size", 18)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(value_label)

	stats_container.add_child(hbox)


func _on_menu_pressed() -> void:
	GameManager.go_to_main_menu()
