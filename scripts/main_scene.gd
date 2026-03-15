extends Node3D

func _ready():
	_build_environment()
	_build_arena()
	_spawn_player()
	_spawn_enemies()
	_create_hud()
	GameManager.start_battle()

func _build_environment():
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.02, 0.06)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.15, 0.2, 0.25)
	env.ambient_light_energy = 0.5
	env.fog_enabled = true
	env.fog_light_color = Color(0.0, 0.05, 0.1)
	env.fog_density = 0.003
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.light_color = Color(0.3, 0.4, 0.6)
	sun.light_energy = 0.3
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.shadow_enabled = false
	add_child(sun)

func _build_arena():
	var arena = Node3D.new()
	arena.name = "Arena"
	add_child(arena)

	# Floor
	var floor_box = CSGBox3D.new()
	floor_box.size = Vector3(80, 0.5, 80)
	floor_box.position = Vector3(0, -0.25, 0)
	floor_box.use_collision = true
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.04, 0.06, 0.08)
	floor_mat.metallic = 0.8
	floor_mat.roughness = 0.3
	floor_box.material = floor_mat
	arena.add_child(floor_box)

	# Grid lines on floor
	for i in range(-40, 41, 5):
		_add_floor_line(arena, Vector3(float(i), 0.01, 0), Vector3(0.02, 0.01, 80), Color(0, 0.3, 0.4, 0.3))
		_add_floor_line(arena, Vector3(0, 0.01, float(i)), Vector3(80, 0.01, 0.02), Color(0, 0.3, 0.4, 0.3))

	# Outer walls
	_add_wall(arena, Vector3(0, 3, -40), Vector3(80, 6, 0.5))
	_add_wall(arena, Vector3(0, 3, 40), Vector3(80, 6, 0.5))
	_add_wall(arena, Vector3(-40, 3, 0), Vector3(0.5, 6, 80))
	_add_wall(arena, Vector3(40, 3, 0), Vector3(0.5, 6, 80))

	# Cover structures with neon edges
	_add_cover(arena, Vector3(-15, 1.5, -10), Vector3(4, 3, 4), Color(0, 1, 0.8))
	_add_cover(arena, Vector3(15, 1.5, 10), Vector3(4, 3, 4), Color(1, 0, 0.3))
	_add_cover(arena, Vector3(0, 2, 0), Vector3(6, 4, 2), Color(0, 0.5, 1))
	_add_cover(arena, Vector3(-20, 1.5, 20), Vector3(3, 3, 8), Color(0, 1, 0.5))
	_add_cover(arena, Vector3(20, 1.5, -20), Vector3(3, 3, 8), Color(1, 0.2, 0))
	_add_cover(arena, Vector3(-10, 1, 15), Vector3(2, 2, 2), Color(0.5, 0, 1))
	_add_cover(arena, Vector3(10, 1, -15), Vector3(2, 2, 2), Color(1, 0.5, 0))
	_add_cover(arena, Vector3(25, 1.5, 5), Vector3(5, 3, 2), Color(0, 0.8, 0.8))
	_add_cover(arena, Vector3(-25, 1.5, -5), Vector3(5, 3, 2), Color(0, 0.8, 0.8))
	_add_cover(arena, Vector3(-30, 2, -25), Vector3(4, 4, 4), Color(1, 0, 0.5))
	_add_cover(arena, Vector3(30, 2, 25), Vector3(4, 4, 4), Color(0, 1, 0))

	# Neon lights
	var neon_data = [
		[Vector3(-15, 3, -10), Color(0, 1, 0.8)],
		[Vector3(15, 3, 10), Color(1, 0, 0.3)],
		[Vector3(0, 3, 0), Color(0, 0.6, 1)],
		[Vector3(-20, 3, 20), Color(0, 1, 0.5)],
		[Vector3(20, 3, -20), Color(1, 0.2, 0)],
		[Vector3(30, 3, 0), Color(0.5, 0, 1)],
		[Vector3(-30, 3, 0), Color(1, 0.5, 0)],
		[Vector3(0, 3, 30), Color(0, 1, 0)],
		[Vector3(0, 3, -30), Color(1, 0, 0)],
	]
	for n in neon_data:
		var light = OmniLight3D.new()
		light.position = n[0]
		light.light_color = n[1]
		light.light_energy = 2.5
		light.omni_range = 12.0
		light.shadow_enabled = false
		arena.add_child(light)

func _add_floor_line(parent: Node3D, pos: Vector3, size: Vector3, color: Color):
	var line = CSGBox3D.new()
	line.size = size
	line.position = pos
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.5
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	line.material = mat
	parent.add_child(line)

func _add_wall(parent: Node3D, pos: Vector3, size: Vector3):
	var wall = CSGBox3D.new()
	wall.size = size
	wall.position = pos
	wall.use_collision = true
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.06, 0.08, 0.12)
	mat.metallic = 0.9
	mat.roughness = 0.2
	wall.material = mat
	parent.add_child(wall)

func _add_cover(parent: Node3D, pos: Vector3, size: Vector3, glow_color: Color):
	var cover = CSGBox3D.new()
	cover.size = size
	cover.position = pos
	cover.use_collision = true
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.07, 0.1)
	mat.metallic = 0.7
	mat.roughness = 0.4
	cover.material = mat
	parent.add_child(cover)

	# Neon edge on top
	var edge = CSGBox3D.new()
	edge.size = Vector3(size.x + 0.06, 0.04, size.z + 0.06)
	edge.position = Vector3(pos.x, pos.y + size.y / 2.0, pos.z)
	var edge_mat = StandardMaterial3D.new()
	edge_mat.albedo_color = glow_color
	edge_mat.emission_enabled = true
	edge_mat.emission = glow_color
	edge_mat.emission_energy_multiplier = 2.5
	edge.material = edge_mat
	parent.add_child(edge)

func _spawn_player():
	var player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 1, 30)

	var col = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	col.shape = shape
	col.position = Vector3(0, 0.9, 0)
	player.add_child(col)

	var pivot = Node3D.new()
	pivot.name = "CameraPivot"
	pivot.position = Vector3(0, 1.6, 0)
	player.add_child(pivot)

	var camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = 75
	pivot.add_child(camera)

	# Weapon visual
	var weapon_mesh = MeshInstance3D.new()
	weapon_mesh.name = "WeaponMesh"
	var box = BoxMesh.new()
	box.size = Vector3(0.06, 0.08, 0.4)
	weapon_mesh.mesh = box
	weapon_mesh.position = Vector3(0.25, -0.15, -0.45)
	var w_mat = StandardMaterial3D.new()
	w_mat.albedo_color = Color(0.3, 0.3, 0.35)
	w_mat.metallic = 0.9
	w_mat.roughness = 0.2
	weapon_mesh.material_override = w_mat
	pivot.add_child(weapon_mesh)

	# Muzzle flash point
	var muzzle = Node3D.new()
	muzzle.name = "MuzzlePoint"
	muzzle.position = Vector3(0.25, -0.12, -0.7)
	pivot.add_child(muzzle)

	player.set_script(load("res://scripts/player.gd"))
	add_child(player)

func _spawn_enemies():
	var positions = [
		Vector3(-15, 0, -15),
		Vector3(15, 0, -20),
		Vector3(-20, 0, 5),
		Vector3(10, 0, -5),
		Vector3(25, 0, 15),
	]
	for i in range(positions.size()):
		_create_enemy("Enemy_%d" % i, positions[i])

func _create_enemy(ename: String, pos: Vector3):
	var enemy = CharacterBody3D.new()
	enemy.name = ename
	enemy.position = pos
	enemy.add_to_group("enemies")

	var col = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	col.shape = shape
	col.position = Vector3(0, 0.9, 0)
	enemy.add_child(col)

	# Body
	var body = MeshInstance3D.new()
	body.name = "Body"
	var capsule_m = CapsuleMesh.new()
	capsule_m.radius = 0.4
	capsule_m.height = 1.8
	body.mesh = capsule_m
	body.position = Vector3(0, 0.9, 0)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.1, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1, 0, 0.2)
	mat.emission_energy_multiplier = 0.5
	body.material_override = mat
	enemy.add_child(body)

	# Head
	var head = MeshInstance3D.new()
	head.name = "Head"
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	head.mesh = sphere
	head.position = Vector3(0, 2.0, 0)
	var h_mat = StandardMaterial3D.new()
	h_mat.albedo_color = Color(0.9, 0.2, 0.1)
	h_mat.emission_enabled = true
	h_mat.emission = Color(1, 0.1, 0)
	h_mat.emission_energy_multiplier = 1.0
	head.material_override = h_mat
	enemy.add_child(head)

	enemy.set_script(load("res://scripts/enemy_bot.gd"))
	add_child(enemy)

func _create_hud():
	var hud = CanvasLayer.new()
	hud.name = "HUD"
	hud.set_script(load("res://scripts/hud_overlay.gd"))
	add_child(hud)
