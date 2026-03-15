extends CharacterBody3D

## AI Bot enemy for single-player testing

const WALK_SPEED: float = 3.5
const GRAVITY: float = 12.0
const MAX_HEALTH: float = 100.0
const DETECTION_RANGE: float = 30.0
const ATTACK_RANGE: float = 20.0
const ATTACK_DAMAGE: float = 8.0
const ATTACK_COOLDOWN: float = 0.5
const PATROL_RADIUS: float = 15.0
const RESPAWN_DELAY: float = 8.0

var health: float = MAX_HEALTH
var is_alive: bool = true
var team: int = 1  # Enemy team by default
var target: Node3D = null
var attack_timer: float = 0.0
var respawn_timer: float = 0.0
var patrol_target: Vector3 = Vector3.ZERO
var patrol_timer: float = 0.0
var spawn_position: Vector3 = Vector3.ZERO
var wander_direction: Vector3 = Vector3.ZERO
var wander_timer: float = 0.0

signal died_at(pos: Vector3, bot_team: int)


func _ready() -> void:
	spawn_position = global_position
	_pick_new_patrol_target()


func _physics_process(delta: float) -> void:
	if not is_alive:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			_respawn()
		return

	if not GameManager.is_battle_active:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Find target
	_find_target()

	if target and is_instance_valid(target):
		var dist: float = global_position.distance_to(target.global_position)

		if dist <= ATTACK_RANGE:
			# Face target
			var look_pos := target.global_position
			look_pos.y = global_position.y
			if look_pos.distance_to(global_position) > 0.1:
				look_at(look_pos, Vector3.UP)

			# Attack
			attack_timer -= delta
			if attack_timer <= 0.0:
				_attack()
				attack_timer = ATTACK_COOLDOWN

			# Strafe while attacking
			var strafe_dir := global_transform.basis.x * sin(Time.get_ticks_msec() * 0.002)
			velocity.x = strafe_dir.x * WALK_SPEED * 0.5
			velocity.z = strafe_dir.z * WALK_SPEED * 0.5
		else:
			# Move toward target
			var dir: Vector3 = (target.global_position - global_position).normalized()
			dir.y = 0.0
			velocity.x = dir.x * WALK_SPEED
			velocity.z = dir.z * WALK_SPEED

			if dir.length() > 0.1:
				var look_pos := global_position + dir
				look_pos.y = global_position.y
				look_at(look_pos, Vector3.UP)
	else:
		# Patrol behavior
		_patrol(delta)

	move_and_slide()


func _find_target() -> void:
	var players := get_tree().get_nodes_in_group("players")
	var closest_dist: float = DETECTION_RANGE
	target = null

	for p in players:
		if not p is CharacterBody3D:
			continue
		if not p.has_method("take_damage"):
			continue
		if p.has_method("get") and p.get("team") == team:
			continue
		if p.has_method("get") and p.get("is_alive") == false:
			continue

		var dist: float = global_position.distance_to(p.global_position)
		if dist < closest_dist:
			closest_dist = dist
			target = p


func _attack() -> void:
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(ATTACK_DAMAGE, global_position)

		# Spawn tracer effect
		_spawn_tracer()


func _spawn_tracer() -> void:
	if not target or not is_instance_valid(target):
		return

	var tracer := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.01
	cyl.bottom_radius = 0.01
	cyl.height = 1.0
	tracer.mesh = cyl

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.3, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.3, 0.1)
	mat.emission_energy_multiplier = 3.0
	tracer.material_override = mat

	get_tree().current_scene.add_child(tracer)

	var start_pos: Vector3 = global_position + Vector3(0, 1.5, 0)
	var end_pos: Vector3 = target.global_position + Vector3(0, 1.0, 0)
	var mid: Vector3 = (start_pos + end_pos) / 2.0
	var dist: float = start_pos.distance_to(end_pos)

	tracer.global_position = mid
	tracer.scale = Vector3(1, dist, 1)
	tracer.look_at(end_pos, Vector3.UP)
	tracer.rotate_object_local(Vector3.RIGHT, PI / 2.0)

	var timer := get_tree().create_timer(0.08)
	timer.timeout.connect(tracer.queue_free)


func _patrol(delta: float) -> void:
	patrol_timer -= delta
	if patrol_timer <= 0.0:
		_pick_new_patrol_target()

	var dir: Vector3 = (patrol_target - global_position).normalized()
	dir.y = 0.0

	if global_position.distance_to(patrol_target) < 2.0:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED * 3.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, WALK_SPEED * 3.0 * delta)
		patrol_timer = 0.0
	else:
		velocity.x = dir.x * WALK_SPEED * 0.6
		velocity.z = dir.z * WALK_SPEED * 0.6
		if dir.length() > 0.1:
			var look_pos := global_position + dir
			look_pos.y = global_position.y
			look_at(look_pos, Vector3.UP)


func _pick_new_patrol_target() -> void:
	var angle: float = randf() * TAU
	var dist: float = randf_range(3.0, PATROL_RADIUS)
	patrol_target = spawn_position + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	patrol_timer = randf_range(3.0, 6.0)


func take_damage(amount: float, from_position: Vector3 = Vector3.ZERO) -> void:
	if not is_alive:
		return
	health -= amount

	if health <= 0.0:
		_die(from_position)


func _die(_from_position: Vector3 = Vector3.ZERO) -> void:
	is_alive = false
	health = 0.0
	respawn_timer = RESPAWN_DELAY

	# Notify for kill tracking
	BattleData.record_kill()
	GameManager.damage_team_life(team, 500)
	died_at.emit(global_position, team)

	# Hide mesh
	visible = false


func _respawn() -> void:
	is_alive = true
	health = MAX_HEALTH
	global_position = spawn_position
	visible = true
	target = null
