extends Control

var player_ref: Node = null

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	await get_tree().process_frame
	player_ref = get_tree().root.get_node_or_null("Main/Player")

func _process(_delta: float):
	queue_redraw()

func _draw():
	var vp = get_viewport_rect().size
	var sw = vp.x
	var sh = vp.y

	_draw_crosshair(vp)
	_draw_touch_controls(sw, sh)
	_draw_hp_bar(sw, sh)
	_draw_timer(sw, sh)
	_draw_team_life(sw, sh)
	_draw_weapon_info(sw, sh)
	_draw_kill_count(sw, sh)
	_draw_reload_indicator(sw, sh)

func _draw_crosshair(vp: Vector2):
	var center = vp / 2.0
	var s = 12.0
	var gap = 4.0
	var col = Color(0, 1, 0.8, 0.8)
	var w = 2.0
	draw_line(center + Vector2(-s, 0), center + Vector2(-gap, 0), col, w)
	draw_line(center + Vector2(gap, 0), center + Vector2(s, 0), col, w)
	draw_line(center + Vector2(0, -s), center + Vector2(0, -gap), col, w)
	draw_line(center + Vector2(0, gap), center + Vector2(0, s), col, w)
	draw_circle(center, 2, Color(0, 1, 0.8, 0.5))

func _draw_touch_controls(sw: float, sh: float):
	# Virtual joystick (when active)
	if player_ref and player_ref.get("move_touch_idx") != null and player_ref.move_touch_idx >= 0:
		var joy_c = player_ref.joystick_center
		var joy_in = player_ref.move_input
		# Outer ring
		draw_arc(joy_c, 80, 0, TAU, 48, Color(0, 1, 0.8, 0.25), 2.0)
		draw_arc(joy_c, 78, 0, TAU, 48, Color(0, 1, 0.8, 0.1), 1.0)
		# Inner stick
		var stick = joy_c + joy_in * 80
		draw_circle(stick, 28, Color(0, 1, 0.8, 0.35))
		draw_arc(stick, 28, 0, TAU, 32, Color(0, 1, 0.8, 0.6), 2.0)
	else:
		# Show joystick hint
		var hint_pos = Vector2(sw * 0.15, sh * 0.65)
		draw_arc(hint_pos, 50, 0, TAU, 32, Color(0.5, 0.5, 0.5, 0.15), 1.5)
		_draw_text_centered("MOVE", hint_pos + Vector2(0, 5), 12, Color(0.5, 0.5, 0.5, 0.3))

	# Shoot button
	var shoot_c = Vector2(sw * 0.87, sh * 0.5)
	var shoot_col = Color(1, 0.2, 0.1, 0.3)
	if player_ref and player_ref.get("is_shooting") and player_ref.is_shooting:
		shoot_col = Color(1, 0.2, 0.1, 0.7)
	draw_circle(shoot_c, 48, shoot_col)
	draw_arc(shoot_c, 48, 0, TAU, 32, Color(1, 0.3, 0.1, 0.6), 2.0)
	_draw_text_centered("FIRE", shoot_c + Vector2(0, 5), 14, Color(1, 1, 1, 0.8))

	# Jump button
	var jump_c = Vector2(sw * 0.92, sh * 0.18)
	draw_circle(jump_c, 32, Color(0, 0.5, 1, 0.25))
	draw_arc(jump_c, 32, 0, TAU, 32, Color(0, 0.6, 1, 0.5), 1.5)
	_draw_text_centered("JUMP", jump_c + Vector2(0, 5), 11, Color(1, 1, 1, 0.7))

	# Reload button
	var reload_c = Vector2(sw * 0.92, sh * 0.82)
	var rld_col = Color(0.8, 0.8, 0, 0.25)
	if player_ref and player_ref.get("is_reloading") and player_ref.is_reloading:
		rld_col = Color(0.8, 0.8, 0, 0.6)
	draw_circle(reload_c, 32, rld_col)
	draw_arc(reload_c, 32, 0, TAU, 32, Color(0.9, 0.9, 0, 0.5), 1.5)
	_draw_text_centered("RLD", reload_c + Vector2(0, 5), 11, Color(1, 1, 1, 0.7))

	# Weapon switch
	var wpn_c = Vector2(sw * 0.72, sh * 0.87)
	draw_circle(wpn_c, 30, Color(0.5, 0, 1, 0.25))
	draw_arc(wpn_c, 30, 0, TAU, 32, Color(0.6, 0, 1, 0.5), 1.5)
	_draw_text_centered("WPN", wpn_c + Vector2(0, 5), 11, Color(1, 1, 1, 0.7))

	# Dash toggle
	var dash_c = Vector2(sw * 0.72, sh * 0.62)
	var dash_col = Color(0, 0.8, 0.5, 0.2)
	if player_ref and player_ref.get("is_sprinting") and player_ref.is_sprinting:
		dash_col = Color(0, 1, 0.5, 0.5)
	draw_circle(dash_c, 28, dash_col)
	draw_arc(dash_c, 28, 0, TAU, 32, Color(0, 0.8, 0.5, 0.5), 1.5)
	_draw_text_centered("DASH", dash_c + Vector2(0, 5), 10, Color(1, 1, 1, 0.7))

func _draw_hp_bar(sw: float, _sh: float):
	var x = 20.0
	var y = 50.0
	var w = 180.0
	var h = 16.0
	var ratio = float(GameManager.player_hp) / float(GameManager.player_max_hp)
	var hp_color = Color(0, 1, 0.5, 0.9) if ratio > 0.3 else Color(1, 0.2, 0, 0.9)

	# Background
	draw_rect(Rect2(x, y, w, h), Color(0.1, 0.1, 0.1, 0.6))
	# HP fill
	draw_rect(Rect2(x, y, w * ratio, h), hp_color)
	# Border
	draw_rect(Rect2(x, y, w, h), Color(0, 1, 0.8, 0.4), false, 1.0)
	# Text
	_draw_text_left("HP %d" % GameManager.player_hp, Vector2(x + 5, y + 13), 12, Color.WHITE)

func _draw_timer(sw: float, _sh: float):
	var t = GameManager.battle_time
	var mins = int(t) / 60
	var secs = int(t) % 60
	var time_str = "%d:%02d" % [mins, secs]
	var col = Color(1, 1, 1, 0.9) if t > 60 else Color(1, 0.3, 0.1, 0.9)
	_draw_text_centered(time_str, Vector2(sw / 2.0, 35), 22, col)

func _draw_team_life(sw: float, _sh: float):
	var bar_w = sw * 0.2
	var bar_h = 10.0
	var y = 15.0

	# Alpha (our team - left)
	var alpha_x = sw * 0.15
	var alpha_ratio = float(GameManager.team_life_alpha) / 100000.0
	draw_rect(Rect2(alpha_x, y, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.5))
	draw_rect(Rect2(alpha_x, y, bar_w * alpha_ratio, bar_h), Color(0, 0.7, 1, 0.8))
	draw_rect(Rect2(alpha_x, y, bar_w, bar_h), Color(0, 0.8, 1, 0.3), false, 1.0)
	_draw_text_left("%dk" % (GameManager.team_life_alpha / 1000), Vector2(alpha_x, y + bar_h + 14), 11, Color(0, 0.8, 1, 0.7))

	# Beta (enemy - right)
	var beta_x = sw * 0.65
	var beta_ratio = float(GameManager.team_life_beta) / 100000.0
	draw_rect(Rect2(beta_x, y, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.5))
	draw_rect(Rect2(beta_x, y, bar_w * beta_ratio, bar_h), Color(1, 0.2, 0.1, 0.8))
	draw_rect(Rect2(beta_x, y, bar_w, bar_h), Color(1, 0.2, 0.1, 0.3), false, 1.0)
	_draw_text_left("%dk" % (GameManager.team_life_beta / 1000), Vector2(beta_x, y + bar_h + 14), 11, Color(1, 0.3, 0.1, 0.7))

func _draw_weapon_info(sw: float, sh: float):
	var weapon = GameManager.get_weapon()
	var x = sw * 0.73
	var y = sh * 0.72

	# Weapon name
	_draw_text_left(weapon["name"], Vector2(x, y), 14, Color(0, 1, 0.8, 0.8))
	# Ammo
	var ammo_str = "%d / %d" % [weapon["current_ammo"], weapon["mag_size"]]
	var ammo_col = Color(1, 1, 1, 0.8) if weapon["current_ammo"] > 0 else Color(1, 0.2, 0, 0.9)
	_draw_text_left(ammo_str, Vector2(x, y + 18), 16, ammo_col)

func _draw_kill_count(_sw: float, sh: float):
	_draw_text_left("Kills: %d" % GameManager.player_kills, Vector2(20, sh - 25), 13, Color(1, 1, 1, 0.6))
	_draw_text_left("Souls: %d" % GameManager.souls_collected, Vector2(20, sh - 10), 13, Color(0, 1, 0.8, 0.6))

func _draw_reload_indicator(sw: float, sh: float):
	if player_ref and player_ref.get("is_reloading") and player_ref.is_reloading:
		var center = Vector2(sw / 2.0, sh / 2.0 + 30)
		var weapon = GameManager.get_weapon()
		var progress = 1.0 - (player_ref.reload_timer / weapon["reload_time"])
		# Arc indicator
		draw_arc(center, 20, -PI / 2.0, -PI / 2.0 + TAU * progress, 32, Color(0.8, 0.8, 0, 0.8), 3.0)
		_draw_text_centered("RELOADING", center + Vector2(0, 25), 12, Color(0.8, 0.8, 0, 0.7))

func _draw_text_centered(text: String, pos: Vector2, font_size: int, color: Color):
	var font = ThemeDB.fallback_font
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, Vector2(pos.x - text_size.x / 2.0, pos.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_text_left(text: String, pos: Vector2, font_size: int, color: Color):
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
