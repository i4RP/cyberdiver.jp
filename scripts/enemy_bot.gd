extends CharacterBody3D

var hp: int = 100
var max_hp: int = 100
var speed: float = 2.0
var patrol_target: Vector3 = Vector3.ZERO
var is_alive: bool = true
var respawn_timer: float = 0.0
var original_position: Vector3 = Vector3.ZERO

const RESPAWN_TIME: float = 5.0
const GRAVITY: float = 15.0

func _ready():
	original_position = position
	patrol_target = _random_patrol_point()

func _physics_process(delta: float):
	if not is_alive:
		respawn_timer -= delta
		if respawn_timer <= 0:
			_respawn()
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Simple patrol
	var dir = patrol_target - position
	dir.y = 0
	if dir.length() < 2.0:
		patrol_target = _random_patrol_point()
		dir = patrol_target - position
		dir.y = 0

	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		# Face movement direction
		var look_pos = position + dir
		look_pos.y = position.y
		look_at(look_pos, Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func take_damage(damage: int):
	if not is_alive:
		return
	hp -= damage

	# Flash red on hit
	var body = get_node_or_null("Body")
	if body and body.material_override:
		var mat = body.material_override as StandardMaterial3D
		if mat:
			mat.emission_energy_multiplier = 3.0
			get_tree().create_timer(0.1).timeout.connect(func():
				if is_instance_valid(body) and mat:
					mat.emission_energy_multiplier = 0.5
			)

	if hp <= 0:
		_die()

func _die():
	is_alive = false
	hp = 0
	visible = false
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", true)

	respawn_timer = RESPAWN_TIME
	GameManager.player_kills += 1
	GameManager.team_life_beta -= 2000

	# Spawn cyber soul
	_spawn_cyber_soul()

func _respawn():
	is_alive = true
	hp = max_hp
	visible = true
	position = original_position
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", false)
	patrol_target = _random_patrol_point()

func _spawn_cyber_soul():
	var soul = Area3D.new()
	soul.name = "CyberSoul"
	soul.position = position + Vector3(0, 0.5, 0)
	soul.add_to_group("cyber_souls")

	var col = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.8
	col.shape = sphere_shape
	soul.add_child(col)

	var mesh = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.3
	mesh.mesh = sphere_mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 1, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(0, 1, 0.8)
	mat.emission_energy_multiplier = 3.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.8
	mesh.material_override = mat
	soul.add_child(mesh)

	var light = OmniLight3D.new()
	light.light_color = Color(0, 1, 0.8)
	light.light_energy = 2.0
	light.omni_range = 5.0
	soul.add_child(light)

	get_tree().root.add_child(soul)

	# Soul bobbing animation and auto-despawn
	soul.set_script(load("res://scripts/cyber_soul.gd"))

func _random_patrol_point() -> Vector3:
	return Vector3(
		randf_range(-35, 35),
		0,
		randf_range(-35, 35)
	)
