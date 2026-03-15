extends CharacterBody3D

const SPEED: float = 5.0
const SPRINT_SPEED: float = 8.0
const JUMP_VELOCITY: float = 5.0
const GRAVITY: float = 15.0
const TOUCH_LOOK_SENS: float = 0.004
const MOUSE_LOOK_SENS: float = 0.002

var camera_pivot: Node3D
var camera: Camera3D

# Touch state - exposed for HUD drawing
var move_touch_idx: int = -1
var look_touch_idx: int = -1
var shoot_touch_idx: int = -1
var joystick_center: Vector2 = Vector2.ZERO
var move_input: Vector2 = Vector2.ZERO
var is_shooting: bool = false
var is_sprinting: bool = false

# Shooting
var fire_cooldown: float = 0.0
var reload_timer: float = 0.0
var is_reloading: bool = false

# Desktop
var mouse_captured: bool = false
var _weapon_switch_pressed: bool = false

func _ready():
	camera_pivot = get_node("CameraPivot")
	camera = get_node("CameraPivot/Camera3D")

func _input(event: InputEvent):
	var vp_size = get_viewport().get_visible_rect().size

	# Mouse capture toggle (desktop)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			mouse_captured = true

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			mouse_captured = false

	# Mouse look (desktop)
	if event is InputEventMouseMotion and mouse_captured:
		rotate_y(-event.relative.x * MOUSE_LOOK_SENS)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_LOOK_SENS)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, deg_to_rad(-85), deg_to_rad(85))

	# Touch events
	if event is InputEventScreenTouch:
		_handle_screen_touch(event, vp_size)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event, vp_size)

func _handle_screen_touch(event: InputEventScreenTouch, vp_size: Vector2):
	var pos = event.position
	var sw = vp_size.x
	var sh = vp_size.y

	if event.pressed:
		# Shoot button (right center area)
		if pos.x > sw * 0.75 and pos.y > sh * 0.25 and pos.y < sh * 0.75:
			shoot_touch_idx = event.index
			is_shooting = true
		# Jump button (top right)
		elif pos.x > sw * 0.82 and pos.y < sh * 0.3:
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
		# Reload button (bottom right)
		elif pos.x > sw * 0.82 and pos.y > sh * 0.7:
			_start_reload()
		# Weapon switch (mid-right bottom)
		elif pos.x > sw * 0.65 and pos.x < sw * 0.78 and pos.y > sh * 0.75:
			GameManager.next_weapon()
		# Dash toggle (mid-right)
		elif pos.x > sw * 0.65 and pos.x < sw * 0.78 and pos.y > sh * 0.5 and pos.y < sh * 0.75:
			is_sprinting = !is_sprinting
		# Movement joystick (left 35%)
		elif pos.x < sw * 0.35:
			move_touch_idx = event.index
			joystick_center = pos
			move_input = Vector2.ZERO
		# Look area (center/right, not on buttons)
		else:
			look_touch_idx = event.index
	else:
		# Touch released
		if event.index == move_touch_idx:
			move_touch_idx = -1
			move_input = Vector2.ZERO
		if event.index == look_touch_idx:
			look_touch_idx = -1
		if event.index == shoot_touch_idx:
			shoot_touch_idx = -1
			is_shooting = false

func _handle_screen_drag(event: InputEventScreenDrag, _vp_size: Vector2):
	if event.index == move_touch_idx:
		var delta = event.position - joystick_center
		var max_dist = 80.0
		if delta.length() > max_dist:
			delta = delta.normalized() * max_dist
		move_input = delta / max_dist
	elif event.index == look_touch_idx:
		rotate_y(-event.relative.x * TOUCH_LOOK_SENS)
		camera_pivot.rotate_x(-event.relative.y * TOUCH_LOOK_SENS)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float):
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Movement input
	var input_dir = Vector2.ZERO
	if move_touch_idx >= 0:
		input_dir = move_input
	else:
		# Keyboard fallback
		if Input.is_key_pressed(KEY_W):
			input_dir.y -= 1
		if Input.is_key_pressed(KEY_S):
			input_dir.y += 1
		if Input.is_key_pressed(KEY_A):
			input_dir.x -= 1
		if Input.is_key_pressed(KEY_D):
			input_dir.x += 1
		if input_dir.length() > 1:
			input_dir = input_dir.normalized()

		# Keyboard actions
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mouse_captured:
			is_shooting = true
		elif shoot_touch_idx < 0:
			is_shooting = false

		if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if Input.is_key_pressed(KEY_R):
			_start_reload()

		if Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_E):
			if not _weapon_switch_pressed:
				GameManager.next_weapon()
				_weapon_switch_pressed = true
		else:
			_weapon_switch_pressed = false

		is_sprinting = Input.is_key_pressed(KEY_SHIFT)

	# Apply movement
	var speed = SPRINT_SPEED if is_sprinting else SPEED
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 10 * delta)
		velocity.z = move_toward(velocity.z, 0, speed * 10 * delta)

	move_and_slide()

	# Fire cooldown
	if fire_cooldown > 0:
		fire_cooldown -= delta

	# Reload
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			is_reloading = false
			GameManager.reload_weapon()

	# Shooting
	if is_shooting and fire_cooldown <= 0 and not is_reloading:
		_fire()

func _fire():
	var weapon = GameManager.get_weapon()
	if GameManager.fire_weapon():
		fire_cooldown = weapon["fire_rate"]
		_do_raycast(weapon)
	else:
		_start_reload()

func _start_reload():
	if is_reloading:
		return
	var weapon = GameManager.get_weapon()
	if weapon["current_ammo"] < weapon["mag_size"]:
		is_reloading = true
		reload_timer = weapon["reload_time"]

func _do_raycast(weapon: Dictionary):
	var space = get_world_3d().direct_space_state
	var from = camera.global_position
	var forward = -camera.global_transform.basis.z
	var spread = weapon["spread"]
	forward += Vector3(
		randf_range(-spread, spread),
		randf_range(-spread, spread),
		randf_range(-spread, spread)
	)
	forward = forward.normalized()
	var to = from + forward * 200.0

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	var result = space.intersect_ray(query)

	if result:
		_spawn_hit_effect(result.position)
		var collider = result.collider
		if collider.is_in_group("enemies") and collider.has_method("take_damage"):
			collider.take_damage(weapon["damage"])
			GameManager.player_damage_dealt += weapon["damage"]

func _spawn_hit_effect(pos: Vector3):
	var mi = MeshInstance3D.new()
	var s = SphereMesh.new()
	s.radius = 0.08
	mi.mesh = s
	mi.global_position = pos
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0.8, 0)
	mat.emission_enabled = true
	mat.emission = Color(1, 0.5, 0)
	mat.emission_energy_multiplier = 5.0
	mi.material_override = mat
	get_tree().root.add_child(mi)
	get_tree().create_timer(0.2).timeout.connect(mi.queue_free)
