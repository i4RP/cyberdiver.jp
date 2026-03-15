extends Node

## Global game state manager

enum GameState {
	MAIN_MENU,
	BRIEFING,
	BATTLE,
	RESULTS
}

var current_state: GameState = GameState.MAIN_MENU
var player_team: int = 0  # 0 = Team Alpha, 1 = Team Bravo
var selected_gate: String = "A"

# Battle settings
const BRIEFING_TIME: float = 60.0
const BATTLE_TIME: float = 300.0
const TEAM_LIFE_MAX: int = 100000
const RESPAWN_TIME_BASE: float = 5.0
const GATE_HP: int = 500
const GATE_RESPAWN_TIME: float = 90.0

# Current battle state
var battle_timer: float = BATTLE_TIME
var briefing_timer: float = BRIEFING_TIME
var team_life: Array[int] = [TEAM_LIFE_MAX, TEAM_LIFE_MAX]
var is_battle_active: bool = false
var is_briefing_active: bool = false

signal state_changed(new_state: GameState)
signal battle_timer_updated(time_left: float)
signal briefing_timer_updated(time_left: float)
signal team_life_updated(team: int, life: int)
signal battle_ended(winning_team: int)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(new_state)

	match new_state:
		GameState.MAIN_MENU:
			_reset_battle()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.BRIEFING:
			_reset_battle()
			is_briefing_active = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.BATTLE:
			is_briefing_active = false
			is_battle_active = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		GameState.RESULTS:
			is_battle_active = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	if is_briefing_active:
		briefing_timer -= delta
		briefing_timer_updated.emit(briefing_timer)
		if briefing_timer <= 0.0:
			is_briefing_active = false
			start_battle()

	if is_battle_active:
		battle_timer -= delta
		battle_timer_updated.emit(battle_timer)
		if battle_timer <= 0.0:
			battle_timer = 0.0
			_end_battle()


func start_battle() -> void:
	change_state(GameState.BATTLE)


func damage_team_life(team: int, amount: int) -> void:
	if team < 0 or team > 1:
		return
	team_life[team] = maxi(0, team_life[team] - amount)
	team_life_updated.emit(team, team_life[team])

	if team_life[team] <= 0:
		_end_battle()


func _end_battle() -> void:
	is_battle_active = false
	var winning_team: int = 0 if team_life[0] >= team_life[1] else 1
	battle_ended.emit(winning_team)
	change_state(GameState.RESULTS)


func _reset_battle() -> void:
	battle_timer = BATTLE_TIME
	briefing_timer = BRIEFING_TIME
	team_life = [TEAM_LIFE_MAX, TEAM_LIFE_MAX]
	is_battle_active = false
	is_briefing_active = false
	var battle_data := get_node_or_null("/root/BattleData")
	if battle_data:
		battle_data.reset()


func get_battle_time_string() -> String:
	var minutes: int = int(battle_timer) / 60
	var seconds: int = int(battle_timer) % 60
	return "%d:%02d" % [minutes, seconds]


func go_to_main_menu() -> void:
	change_state(GameState.MAIN_MENU)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func go_to_briefing() -> void:
	change_state(GameState.BRIEFING)
	get_tree().change_scene_to_file("res://scenes/briefing_room.tscn")


func go_to_battle() -> void:
	get_tree().change_scene_to_file("res://scenes/battle.tscn")


func go_to_results() -> void:
	change_state(GameState.RESULTS)
	get_tree().change_scene_to_file("res://scenes/results.tscn")
