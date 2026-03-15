extends CharacterBody3D

## FPS Player Controller for CYBERDIVER

const WALK_SPEED: float = 5.0
const SPRINT_SPEED: float = 8.5
const JUMP_VELOCITY: float = 5.5
const MOUSE_SENSITIVITY: float = 0.002
const GRAVITY: float = 12.0
const MAX_HEALTH: float = 100.0
const RESPAWN_DELAY: float = 5.0

@onready var camera: Camera3D = $Head/Camera3D
@onready var head: Node3D = $Head
@onready var weapon_manager: Node3D = $Head/Camera3D/WeaponManager
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var muzzle_flash: OmniLight3D = $Head/Camera3D/WeaponManager/MuzzleFlash

var health: float = MAX_HEALTH
var is_alive: bool = true
var team: int = 0  # 0 = Alpha, 1 = Bravo
var is_sprinting: bool = false
var respawn_timer: float = 0.0

# Weapon system
var weapons: Array[Dictionary] = []
var current_weapon_index: int = 0
var shoot_cooldown: float = 0.0
var reload_timer: float = 0.0
var is_reloading: bool = false
var muzzle_flash_timer: float = 0.0

signal health_changed(new_health: float)
signal died(position: Vector3)
signal weapon_changed(weapon_data: Dictionary)
signal ammo_changed(current: int, reserve: int)
signal respawned()


func _ready() -> void:
	_setup_weapons()
	_emit_weapon_info()
	if muzzle_flash:
		muzzle_flash.visible = false


func _setup_weapons() -> void:
	weapons = [
		{
			"name": "Handgun",
			"damage": 25.0,
			"fire_rate": 0.4,
			"bullet_speed": 100.0,
			"magazine_size": 12,
			"current_ammo": 12,
			"reserve_ammo": 48,
			"reload_time": 1.5,
			"spread": 0.01,
			"range": 100.0,
			"auto_fire": false
		},
		{
			"name": "Cyber Rifle",
			"damage": 15.0,
			"fire_rate": 0.1,
			"bullet_speed": 80.0,
			"magazine_size": 30,
			"current_ammo": 30,
			"reserve_ammo": 120,
			"reload_time": 2.0,
			"spread": 0.04,
			"range": 80.0,
			"auto_fire": true
		},
		{
			"name": "Sniper Rifle",
			"damage": 80.0,
			"fire_rate": 1.2,
			"bullet_speed": 200.0,
			"magazine_size": 5,
			"current_ammo": 5,
			"reserve_ammo": 20,
			"reload_time": 3.0,
			"spread": 0.002,
			"range": 200.0,
			"auto_fire": false
		}
	]
	current_weapon_index = 0


func _input(event: InputEvent) -> void:
	if not is_alive:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clampf(camera.rotation.x, -PI / 2.0, PI / 2.0)

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_switch_weapon(-1)
			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_switch_weapon(1)

	if event.is_action_pressed("weapon_next"):
		_switch_weapon(1)
	elif event.is_action_pressed("weapon_prev"):
		_switch_weapon(-1)

	if event.is_action_pressed("reload") and not is_reloading:
		_start_reload()


func _physics_process(delta: float) -> void:
	if not is_alive:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			_respawn()
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Sprint
	is_sprinting = Input.is_action_pressed("sprint")
	var speed: float = SPRINT_SPEED if is_sprinting else WALK_SPEED

	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0.0, speed * 5.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, speed * 5.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, direction.x * speed, 2.0 * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, 2.0 * delta)

	move_and_slide()

	# Shooting
	shoot_cooldown -= delta
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0.0:
			_finish_reload()
	elif Input.is_action_pressed("shoot") and shoot_cooldown <= 0.0:
		var weapon: Dictionary = weapons[current_weapon_index]
		if weapon["auto_fire"] or Input.is_action_just_pressed("shoot"):
			_shoot()

	# Muzzle flash timer
	if muzzle_flash_timer > 0.0:
		muzzle_flash_timer -= delta
		if muzzle_flash_timer <= 0.0 and muzzle_flash:
			muzzle_flash.visible = false


func _shoot() -> void:
	var weapon: Dictionary = weapons[current_weapon_index]

	if weapon["current_ammo"] <= 0:
		_start_reload()
		return

	weapon["current_ammo"] -= 1
	shoot_cooldown = weapon["fire_rate"]
	ammo_changed.emit(weapon["current_ammo"], weapon["reserve_ammo"])

	# Muzzle flash
	if muzzle_flash:
		muzzle_flash.visible = true
		muzzle_flash_timer = 0.05

	# Raycast hit detection
	if raycast and raycast.is_colliding():
		var collider := raycast.get_collider()
		var hit_point: Vector3 = raycast.get_collision_point()
		var hit_normal: Vector3 = raycast.get_collision_normal()

		# Apply spread
		var spread_amount: float = weapon["spread"]
		if is_sprinting:
			spread_amount *= 2.0

		if collider.has_method("take_damage"):
			var actual_damage: float = weapon["damage"]
			collider.take_damage(actual_damage, global_position)
			BattleData.record_damage_dealt(actual_damage)

		# Spawn hit effect
		_spawn_hit_effect(hit_point, hit_normal)


func _spawn_hit_effect(hit_pos: Vector3, hit_normal: Vector3) -> void:
	var effect := GPUParticles3D.new()
	effect.emitting = true
	effect.one_shot = true
	effect.amount = 8
	effect.lifetime = 0.3
	effect.global_position = hit_pos

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(hit_normal.x, hit_normal.y, hit_normal.z)
	mat.spread = 30.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 5.0
	mat.gravity = Vector3(0, -5, 0)
	mat.color = Color(1.0, 0.8, 0.3)
	effect.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.02
	mesh.height = 0.04
	effect.draw_pass_1 = mesh

	get_tree().current_scene.add_child(effect)
	# Auto-free after lifetime
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(effect.queue_free)


func _switch_weapon(direction: int) -> void:
	if is_reloading:
		is_reloading = false
	current_weapon_index = wrapi(current_weapon_index + direction, 0, weapons.size())
	_emit_weapon_info()


func _emit_weapon_info() -> void:
	if weapons.size() > 0:
		var w: Dictionary = weapons[current_weapon_index]
		weapon_changed.emit(w)
		ammo_changed.emit(w["current_ammo"], w["reserve_ammo"])


func _start_reload() -> void:
	var weapon: Dictionary = weapons[current_weapon_index]
	if weapon["current_ammo"] >= weapon["magazine_size"]:
		return
	if weapon["reserve_ammo"] <= 0:
		return
	is_reloading = true
	reload_timer = weapon["reload_time"]


func _finish_reload() -> void:
	var weapon: Dictionary = weapons[current_weapon_index]
	var needed: int = weapon["magazine_size"] - weapon["current_ammo"]
	var available: int = mini(needed, weapon["reserve_ammo"])
	weapon["current_ammo"] += available
	weapon["reserve_ammo"] -= available
	is_reloading = false
	ammo_changed.emit(weapon["current_ammo"], weapon["reserve_ammo"])


func take_damage(amount: float, _from_position: Vector3 = Vector3.ZERO) -> void:
	if not is_alive:
		return
	health -= amount
	health_changed.emit(health)
	BattleData.record_damage_taken(amount)

	if health <= 0.0:
		_die()


func heal(amount: float) -> void:
	health = minf(health + amount, MAX_HEALTH)
	health_changed.emit(health)


func _die() -> void:
	is_alive = false
	health = 0.0
	respawn_timer = RESPAWN_DELAY
	BattleData.record_death()
	died.emit(global_position)

	# Damage own team life
	GameManager.damage_team_life(team, 500)


func _respawn() -> void:
	is_alive = true
	health = MAX_HEALTH
	health_changed.emit(health)
	# Reset ammo
	for w in weapons:
		w["current_ammo"] = w["magazine_size"]
	_emit_weapon_info()
	respawned.emit()


func get_current_weapon() -> Dictionary:
	if weapons.size() > 0:
		return weapons[current_weapon_index]
	return {}
