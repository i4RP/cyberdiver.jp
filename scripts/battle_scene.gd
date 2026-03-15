extends Node3D

## Main battle scene controller

@onready var player: CharacterBody3D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var spawn_points_alpha: Node3D = $SpawnPointsAlpha
@onready var spawn_points_bravo: Node3D = $SpawnPointsBravo

var cyber_soul_scene: PackedScene = null
var enemy_bots: Array[Node] = []


func _ready() -> void:
	# Connect HUD to player
	if hud and player:
		hud.connect_player(player)

	# Set player team
	player.team = GameManager.player_team
	player.add_to_group("players")

	# Spawn player at selected gate
	_spawn_player_at_gate()

	# Spawn enemy bots
	_spawn_bots()

	# Connect signals
	GameManager.battle_ended.connect(_on_battle_ended)
	player.died.connect(_on_player_died)

	# Start battle
	if not GameManager.is_battle_active:
		GameManager.change_state(GameManager.GameState.BATTLE)

	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _spawn_player_at_gate() -> void:
	var gate_index: int = ["A", "B", "C", "D", "E"].find(GameManager.selected_gate)
	if gate_index < 0:
		gate_index = 0

	if spawn_points_alpha and spawn_points_alpha.get_child_count() > gate_index:
		var spawn: Node3D = spawn_points_alpha.get_child(gate_index)
		player.global_position = spawn.global_position


func _spawn_bots() -> void:
	if not spawn_points_bravo:
		return

	for i in range(mini(5, spawn_points_bravo.get_child_count())):
		var spawn_point: Node3D = spawn_points_bravo.get_child(i)
		var bot := _create_bot(spawn_point.global_position, 1)
		bot.died_at.connect(_on_bot_died)
		enemy_bots.append(bot)


func _create_bot(pos: Vector3, bot_team: int) -> CharacterBody3D:
	var bot := CharacterBody3D.new()
	bot.global_position = pos

	# Collision shape
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	collision.shape = capsule
	collision.position = Vector3(0, 0.9, 0)
	bot.add_child(collision)

	# Visual body
	var body_mesh := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.35
	capsule_mesh.height = 1.6
	body_mesh.mesh = capsule_mesh
	body_mesh.position = Vector3(0, 0.9, 0)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.15, 0.15)
	mat.emission_enabled = true
	mat.emission = Color(0.6, 0.1, 0.1)
	mat.emission_energy_multiplier = 0.5
	body_mesh.material_override = mat
	bot.add_child(body_mesh)

	# Head
	var head_mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.25
	sphere.height = 0.5
	head_mesh.mesh = sphere
	head_mesh.position = Vector3(0, 1.9, 0)

	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.9, 0.2, 0.2)
	head_mat.emission_enabled = true
	head_mat.emission = Color(1.0, 0.1, 0.1)
	head_mat.emission_energy_multiplier = 1.0
	head_mesh.material_override = head_mat
	bot.add_child(head_mesh)

	# Eye glow
	var eye_light := OmniLight3D.new()
	eye_light.light_color = Color(1.0, 0.1, 0.1)
	eye_light.light_energy = 0.5
	eye_light.omni_range = 2.0
	eye_light.position = Vector3(0, 1.9, -0.2)
	bot.add_child(eye_light)

	# Attach bot script
	var script := load("res://scripts/enemy_bot.gd")
	bot.set_script(script)
	bot.team = bot_team

	bot.set_collision_layer_value(1, false)
	bot.set_collision_layer_value(3, true)
	bot.set_collision_mask_value(1, true)
	bot.set_collision_mask_value(2, true)

	add_child(bot)
	return bot


func _on_bot_died(pos: Vector3, bot_team: int) -> void:
	_spawn_cyber_soul(pos, bot_team)
	if hud:
		hud.add_kill_feed_entry("Player", "Bot")


func _on_player_died(pos: Vector3) -> void:
	_spawn_cyber_soul(pos, player.team)
	BattleData.record_soul_lost()


func _spawn_cyber_soul(pos: Vector3, soul_team: int) -> void:
	var soul := Area3D.new()
	soul.global_position = pos

	# Collision for pickup
	var col := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 1.5
	col.shape = sphere_shape
	soul.add_child(col)

	# Attach script
	var script := load("res://scripts/cyber_soul.gd")
	soul.set_script(script)
	soul.soul_team = soul_team

	soul.set_collision_layer_value(1, false)
	soul.set_collision_layer_value(5, true)
	soul.set_collision_mask_value(2, true)
	soul.set_collision_mask_value(3, true)

	add_child(soul)


func _on_battle_ended(winning_team: int) -> void:
	var won: bool = winning_team == player.team
	var perfect: bool = GameManager.team_life[1 - player.team] <= 0
	BattleData.finalize(
		won,
		perfect,
		GameManager.team_life[player.team],
		GameManager.team_life[1 - player.team]
	)

	# Short delay before results
	await get_tree().create_timer(2.0).timeout
	GameManager.go_to_results()
