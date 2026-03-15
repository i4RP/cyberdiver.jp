extends CanvasLayer

## Battle HUD - displays health, ammo, team life, timer, crosshair

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/BottomHUD/HealthPanel/HealthBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/BottomHUD/HealthPanel/HealthLabel
@onready var ammo_label: Label = $MarginContainer/VBoxContainer/BottomHUD/AmmoPanel/AmmoLabel
@onready var weapon_label: Label = $MarginContainer/VBoxContainer/BottomHUD/AmmoPanel/WeaponLabel
@onready var timer_label: Label = $MarginContainer/VBoxContainer/TopHUD/TimerPanel/TimerLabel
@onready var team_alpha_bar: ProgressBar = $MarginContainer/VBoxContainer/TopHUD/TeamAlphaPanel/TeamAlphaBar
@onready var team_alpha_label: Label = $MarginContainer/VBoxContainer/TopHUD/TeamAlphaPanel/TeamAlphaLabel
@onready var team_bravo_bar: ProgressBar = $MarginContainer/VBoxContainer/TopHUD/TeamBravoPanel/TeamBravoBar
@onready var team_bravo_label: Label = $MarginContainer/VBoxContainer/TopHUD/TeamBravoPanel/TeamBravoLabel
@onready var crosshair: TextureRect = $Crosshair
@onready var kill_feed: VBoxContainer = $KillFeed
@onready var reload_label: Label = $ReloadLabel
@onready var death_overlay: ColorRect = $DeathOverlay
@onready var respawn_label: Label = $DeathOverlay/RespawnLabel


func _ready() -> void:
	GameManager.battle_timer_updated.connect(_on_timer_updated)
	GameManager.team_life_updated.connect(_on_team_life_updated)

	# Initialize
	_update_health(100.0)
	_update_team_life_display(0, GameManager.TEAM_LIFE_MAX)
	_update_team_life_display(1, GameManager.TEAM_LIFE_MAX)
	if death_overlay:
		death_overlay.visible = false
	if reload_label:
		reload_label.visible = false


func connect_player(player: Node) -> void:
	if player.has_signal("health_changed"):
		player.health_changed.connect(_update_health)
	if player.has_signal("weapon_changed"):
		player.weapon_changed.connect(_update_weapon)
	if player.has_signal("ammo_changed"):
		player.ammo_changed.connect(_update_ammo)
	if player.has_signal("died"):
		player.died.connect(_on_player_died)
	if player.has_signal("respawned"):
		player.respawned.connect(_on_player_respawned)


func _update_health(new_health: float) -> void:
	if health_bar:
		health_bar.value = new_health
	if health_label:
		health_label.text = "%d" % int(new_health)


func _update_weapon(weapon_data: Dictionary) -> void:
	if weapon_label:
		weapon_label.text = weapon_data.get("name", "Unknown")
	_update_ammo(
		weapon_data.get("current_ammo", 0),
		weapon_data.get("reserve_ammo", 0)
	)


func _update_ammo(current: int, reserve: int) -> void:
	if ammo_label:
		ammo_label.text = "%d / %d" % [current, reserve]


func _on_timer_updated(time_left: float) -> void:
	if timer_label:
		var minutes: int = int(time_left) / 60
		var seconds: int = int(time_left) % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]


func _on_team_life_updated(team_idx: int, life: int) -> void:
	_update_team_life_display(team_idx, life)


func _update_team_life_display(team_idx: int, life: int) -> void:
	var percentage: float = (float(life) / float(GameManager.TEAM_LIFE_MAX)) * 100.0
	if team_idx == 0:
		if team_alpha_bar:
			team_alpha_bar.value = percentage
		if team_alpha_label:
			team_alpha_label.text = "ALPHA: %d" % life
	else:
		if team_bravo_bar:
			team_bravo_bar.value = percentage
		if team_bravo_label:
			team_bravo_label.text = "BRAVO: %d" % life


func _on_player_died(_pos: Vector3) -> void:
	if death_overlay:
		death_overlay.visible = true
	if crosshair:
		crosshair.visible = false


func _on_player_respawned() -> void:
	if death_overlay:
		death_overlay.visible = false
	if crosshair:
		crosshair.visible = true


func show_reload_indicator(show: bool) -> void:
	if reload_label:
		reload_label.visible = show


func add_kill_feed_entry(killer_name: String, victim_name: String) -> void:
	if not kill_feed:
		return
	var entry := Label.new()
	entry.text = "%s >> %s" % [killer_name, victim_name]
	entry.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	entry.add_theme_font_size_override("font_size", 14)
	kill_feed.add_child(entry)

	# Remove after 5 seconds
	var timer := get_tree().create_timer(5.0)
	timer.timeout.connect(entry.queue_free)
