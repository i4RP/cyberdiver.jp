extends Node3D

func _ready():
	_build_environment()
	_build_facility()
	_spawn_player()
	_spawn_enemies()
	_create_hud()
	GameManager.start_battle()

func _build_environment():
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.01, 0.015, 0.03)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.08, 0.12, 0.18)
	env.ambient_light_energy = 0.4
	env.fog_enabled = true
	env.fog_light_color = Color(0.0, 0.03, 0.06)
	env.fog_density = 0.008
	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.glow_hdr_threshold = 0.8
	env.tonemap_mode = Environment.TONE_MAP_ACES
	env.tonemap_exposure = 1.1
	env.ssao_enabled = true
	env.ssao_radius = 1.0
	env.ssao_intensity = 1.5
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.light_color = Color(0.2, 0.3, 0.5)
	sun.light_energy = 0.15
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.shadow_enabled = false
	add_child(sun)

func _build_facility():
	var facility = Node3D.new()
	facility.name = "Facility"
	add_child(facility)
	_build_floor(facility)
	_build_ceiling(facility)
	_build_perimeter_walls(facility)
	_build_corridors(facility)
	_build_cover_structures(facility)
	_build_neon_strips(facility)
	_build_ceiling_lights(facility)
	_build_decorations(facility)

func _build_floor(parent: Node3D):
	var floor_box = CSGBox3D.new()
	floor_box.size = Vector3(80, 0.5, 80)
	floor_box.position = Vector3(0, -0.25, 0)
	floor_box.use_collision = true
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.03, 0.04, 0.06)
	floor_mat.metallic = 0.9
	floor_mat.roughness = 0.25
	floor_mat.emission_enabled = true
	floor_mat.emission = Color(0.0, 0.02, 0.03)
	floor_mat.emission_energy_multiplier = 0.3
	floor_box.material = floor_mat
	parent.add_child(floor_box)

	for i in range(-40, 41, 4):
		_add_floor_line(parent, Vector3(float(i), 0.01, 0), Vector3(0.03, 0.02, 80), Color(0, 0.4, 0.5, 0.4))
		_add_floor_line(parent, Vector3(0, 0.01, float(i)), Vector3(80, 0.02, 0.03), Color(0, 0.4, 0.5, 0.4))

	_add_floor_line(parent, Vector3(0, 0.02, 0), Vector3(0.15, 0.02, 20), Color(0, 0.8, 1, 0.6))
	_add_floor_line(parent, Vector3(0, 0.02, 0), Vector3(20, 0.02, 0.15), Color(0, 0.8, 1, 0.6))

	for z_off in [-30, 30]:
		for x_off in range(-10, 11, 3):
			_add_floor_line(parent, Vector3(float(x_off), 0.015, float(z_off)), Vector3(1.5, 0.02, 0.3), Color(1, 0.6, 0, 0.5))

func _build_ceiling(parent: Node3D):
	var ceiling = CSGBox3D.new()
	ceiling.size = Vector3(80, 0.5, 80)
	ceiling.position = Vector3(0, 8.25, 0)
	var ceil_mat = StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.03, 0.04, 0.06)
	ceil_mat.metallic = 0.8
	ceil_mat.roughness = 0.3
	ceiling.material = ceil_mat
	parent.add_child(ceiling)

	for i in range(-35, 36, 10):
		_add_beam(parent, Vector3(float(i), 7.5, 0), Vector3(0.4, 1.0, 80), Color(0.06, 0.08, 0.12))
		_add_beam(parent, Vector3(0, 7.5, float(i)), Vector3(80, 1.0, 0.4), Color(0.06, 0.08, 0.12))

func _build_perimeter_walls(parent: Node3D):
	_add_detail_wall(parent, Vector3(0, 4, -40), Vector3(80, 8, 0.8))
	_add_detail_wall(parent, Vector3(0, 4, 40), Vector3(80, 8, 0.8))
	_add_detail_wall(parent, Vector3(-40, 4, 0), Vector3(0.8, 8, 80))
	_add_detail_wall(parent, Vector3(40, 4, 0), Vector3(0.8, 8, 80))

	for i in range(-35, 36, 5):
		_add_wall_panel(parent, Vector3(float(i), 4, -39.5), Vector3(3, 5, 0.3), Color(0.04, 0.06, 0.1))
		_add_wall_panel(parent, Vector3(float(i), 4, 39.5), Vector3(3, 5, 0.3), Color(0.04, 0.06, 0.1))
		_add_wall_panel(parent, Vector3(-39.5, 4, float(i)), Vector3(0.3, 5, 3), Color(0.04, 0.06, 0.1))
		_add_wall_panel(parent, Vector3(39.5, 4, float(i)), Vector3(0.3, 5, 3), Color(0.04, 0.06, 0.1))

	for i in range(-38, 39, 8):
		_add_neon_line(parent, Vector3(float(i), 2.0, -39.6), Vector3(5, 0.08, 0.08), Color(0, 0.8, 1))
		_add_neon_line(parent, Vector3(float(i), 2.0, 39.6), Vector3(5, 0.08, 0.08), Color(1, 0.1, 0.3))
		_add_neon_line(parent, Vector3(-39.6, 2.0, float(i)), Vector3(0.08, 0.08, 5), Color(0, 1, 0.5))
		_add_neon_line(parent, Vector3(39.6, 2.0, float(i)), Vector3(0.08, 0.08, 5), Color(1, 0.5, 0))

func _build_corridors(parent: Node3D):
	var platform = CSGBox3D.new()
	platform.size = Vector3(12, 0.6, 12)
	platform.position = Vector3(0, 0.3, 0)
	platform.use_collision = true
	var plat_mat = StandardMaterial3D.new()
	plat_mat.albedo_color = Color(0.06, 0.08, 0.12)
	plat_mat.metallic = 0.9
	plat_mat.roughness = 0.2
	platform.material = plat_mat
	parent.add_child(platform)

	for side in [
		[Vector3(0, 0.62, -6), Vector3(12, 0.06, 0.06)],
		[Vector3(0, 0.62, 6), Vector3(12, 0.06, 0.06)],
		[Vector3(-6, 0.62, 0), Vector3(0.06, 0.06, 12)],
		[Vector3(6, 0.62, 0), Vector3(0.06, 0.06, 12)],
	]:
		_add_neon_line(parent, side[0], side[1], Color(0, 1, 0.8))

	_add_corridor_section(parent, Vector3(-4, 0, -25), Vector3(8, 6, 20), Color(0, 0.6, 1))
	_add_corridor_section(parent, Vector3(4, 0, 25), Vector3(8, 6, 20), Color(1, 0.2, 0.4))

	_add_room_section(parent, Vector3(-25, 0, -25), Vector3(15, 6, 15), Color(0, 1, 0.5))
	_add_room_section(parent, Vector3(25, 0, 25), Vector3(15, 6, 15), Color(1, 0.3, 0))
	_add_room_section(parent, Vector3(-25, 0, 20), Vector3(12, 6, 12), Color(0.5, 0, 1))
	_add_room_section(parent, Vector3(25, 0, -20), Vector3(12, 6, 12), Color(1, 1, 0))

func _add_corridor_section(parent: Node3D, pos: Vector3, size: Vector3, accent: Color):
	var lw = CSGBox3D.new()
	lw.size = Vector3(0.4, size.y, size.z)
	lw.position = Vector3(pos.x - size.x / 2.0, size.y / 2.0, pos.z)
	lw.use_collision = true
	lw.material = _make_wall_mat()
	parent.add_child(lw)

	var rw = CSGBox3D.new()
	rw.size = Vector3(0.4, size.y, size.z)
	rw.position = Vector3(pos.x + size.x / 2.0, size.y / 2.0, pos.z)
	rw.use_collision = true
	rw.material = _make_wall_mat()
	parent.add_child(rw)

	_add_neon_line(parent, Vector3(pos.x - size.x / 2.0 + 0.25, 2.0, pos.z), Vector3(0.05, 0.05, size.z - 1), accent)
	_add_neon_line(parent, Vector3(pos.x + size.x / 2.0 - 0.25, 2.0, pos.z), Vector3(0.05, 0.05, size.z - 1), accent)

	var light = OmniLight3D.new()
	light.position = Vector3(pos.x, 5.0, pos.z)
	light.light_color = accent
	light.light_energy = 3.0
	light.omni_range = 15.0
	light.shadow_enabled = false
	parent.add_child(light)

func _add_room_section(parent: Node3D, pos: Vector3, size: Vector3, accent: Color):
	var pillar_positions = [
		Vector3(pos.x - size.x / 2.0, 0, pos.z - size.z / 2.0),
		Vector3(pos.x + size.x / 2.0, 0, pos.z - size.z / 2.0),
		Vector3(pos.x - size.x / 2.0, 0, pos.z + size.z / 2.0),
		Vector3(pos.x + size.x / 2.0, 0, pos.z + size.z / 2.0),
	]
	for pp in pillar_positions:
		_add_pillar(parent, pp, 6.0, accent)

	var light = OmniLight3D.new()
	light.position = Vector3(pos.x, 5.5, pos.z)
	light.light_color = accent
	light.light_energy = 2.5
	light.omni_range = 12.0
	light.shadow_enabled = false
	parent.add_child(light)

	_add_neon_line(parent, Vector3(pos.x, 0.015, pos.z), Vector3(size.x * 0.6, 0.02, 0.08), accent * 0.7)
	_add_neon_line(parent, Vector3(pos.x, 0.015, pos.z), Vector3(0.08, 0.02, size.z * 0.6), accent * 0.7)

func _add_pillar(parent: Node3D, pos: Vector3, height: float, accent: Color):
	var pillar = CSGBox3D.new()
	pillar.size = Vector3(0.8, height, 0.8)
	pillar.position = Vector3(pos.x, height / 2.0, pos.z)
	pillar.use_collision = true
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.08, 0.1, 0.15)
	mat.metallic = 0.9
	mat.roughness = 0.15
	pillar.material = mat
	parent.add_child(pillar)

	var strip = CSGBox3D.new()
	strip.size = Vector3(0.1, height - 0.5, 0.1)
	strip.position = Vector3(pos.x + 0.4, height / 2.0, pos.z + 0.4)
	var strip_mat = StandardMaterial3D.new()
	strip_mat.albedo_color = accent
	strip_mat.emission_enabled = true
	strip_mat.emission = accent
	strip_mat.emission_energy_multiplier = 3.0
	strip.material = strip_mat
	parent.add_child(strip)

	var base_cap = CSGBox3D.new()
	base_cap.size = Vector3(1.0, 0.15, 1.0)
	base_cap.position = Vector3(pos.x, 0.075, pos.z)
	base_cap.material = mat
	parent.add_child(base_cap)

	var top_cap = CSGBox3D.new()
	top_cap.size = Vector3(1.0, 0.15, 1.0)
	top_cap.position = Vector3(pos.x, height - 0.075, pos.z)
	top_cap.material = mat
	parent.add_child(top_cap)

func _build_cover_structures(parent: Node3D):
	var covers = [
		[Vector3(-15, 0, -10), Vector3(4, 3, 4), Color(0, 1, 0.8)],
		[Vector3(15, 0, 10), Vector3(4, 3, 4), Color(1, 0, 0.3)],
		[Vector3(0, 0, 0), Vector3(3, 2, 3), Color(0, 0.5, 1)],
		[Vector3(-20, 0, 20), Vector3(3, 3, 8), Color(0, 1, 0.5)],
		[Vector3(20, 0, -20), Vector3(3, 3, 8), Color(1, 0.2, 0)],
		[Vector3(-10, 0, 15), Vector3(2, 2, 2), Color(0.5, 0, 1)],
		[Vector3(10, 0, -15), Vector3(2, 2, 2), Color(1, 0.5, 0)],
		[Vector3(25, 0, 5), Vector3(5, 3, 2), Color(0, 0.8, 0.8)],
		[Vector3(-25, 0, -5), Vector3(5, 3, 2), Color(0, 0.8, 0.8)],
		[Vector3(-30, 0, -25), Vector3(4, 4, 4), Color(1, 0, 0.5)],
		[Vector3(30, 0, 25), Vector3(4, 4, 4), Color(0, 1, 0)],
		[Vector3(-8, 0, -25), Vector3(6, 2.5, 1.5), Color(0, 0.7, 1)],
		[Vector3(8, 0, 25), Vector3(6, 2.5, 1.5), Color(1, 0, 0.5)],
		[Vector3(-33, 0, 10), Vector3(2, 4, 6), Color(0.3, 0, 1)],
		[Vector3(33, 0, -10), Vector3(2, 4, 6), Color(1, 0.8, 0)],
	]
	for c in covers:
		_add_detailed_cover(parent, c[0], c[1], c[2])

func _add_detailed_cover(parent: Node3D, pos: Vector3, size: Vector3, accent: Color):
	var body = CSGBox3D.new()
	body.size = size
	body.position = Vector3(pos.x, size.y / 2.0, pos.z)
	body.use_collision = true
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.07, 0.1)
	mat.metallic = 0.85
	mat.roughness = 0.2
	body.material = mat
	parent.add_child(body)

	var edge_mat = StandardMaterial3D.new()
	edge_mat.albedo_color = accent
	edge_mat.emission_enabled = true
	edge_mat.emission = accent
	edge_mat.emission_energy_multiplier = 3.5

	var edge = CSGBox3D.new()
	edge.size = Vector3(size.x + 0.1, 0.06, size.z + 0.1)
	edge.position = Vector3(pos.x, size.y + 0.03, pos.z)
	edge.material = edge_mat
	parent.add_child(edge)

	var bottom_edge = CSGBox3D.new()
	bottom_edge.size = Vector3(size.x + 0.1, 0.06, size.z + 0.1)
	bottom_edge.position = Vector3(pos.x, 0.03, pos.z)
	bottom_edge.material = edge_mat
	parent.add_child(bottom_edge)

	var half_x = size.x / 2.0
	var half_z = size.z / 2.0
	for corner in [
		Vector3(pos.x - half_x, size.y / 2.0, pos.z - half_z),
		Vector3(pos.x + half_x, size.y / 2.0, pos.z + half_z),
	]:
		var v_strip = CSGBox3D.new()
		v_strip.size = Vector3(0.05, size.y, 0.05)
		v_strip.position = corner
		v_strip.material = edge_mat
		parent.add_child(v_strip)

	var panel = CSGBox3D.new()
	panel.size = Vector3(size.x * 0.6, size.y * 0.4, 0.08)
	panel.position = Vector3(pos.x, size.y * 0.6, pos.z - size.z / 2.0 - 0.04)
	var panel_mat = StandardMaterial3D.new()
	panel_mat.albedo_color = Color(0.04, 0.05, 0.08)
	panel_mat.metallic = 0.95
	panel_mat.roughness = 0.1
	panel.material = panel_mat
	parent.add_child(panel)

func _build_neon_strips(parent: Node3D):
	for z in range(-35, 36, 3):
		if z > 15:
			_add_neon_line(parent, Vector3(-2, 0.02, float(z)), Vector3(0.5, 0.03, 0.1), Color(0, 0.8, 1))
			_add_neon_line(parent, Vector3(2, 0.02, float(z)), Vector3(0.5, 0.03, 0.1), Color(0, 0.8, 1))
		elif z < -15:
			_add_neon_line(parent, Vector3(-2, 0.02, float(z)), Vector3(0.5, 0.03, 0.1), Color(1, 0.1, 0.2))
			_add_neon_line(parent, Vector3(2, 0.02, float(z)), Vector3(0.5, 0.03, 0.1), Color(1, 0.1, 0.2))

func _build_ceiling_lights(parent: Node3D):
	var light_positions = [
		[Vector3(0, 7.5, 0), Color(0.7, 0.8, 1.0), 4.0, 18.0],
		[Vector3(-20, 7.0, 0), Color(0, 0.6, 1), 2.5, 14.0],
		[Vector3(20, 7.0, 0), Color(1, 0.3, 0.1), 2.5, 14.0],
		[Vector3(0, 7.0, -20), Color(0, 1, 0.6), 2.5, 14.0],
		[Vector3(0, 7.0, 20), Color(1, 0, 0.5), 2.5, 14.0],
		[Vector3(-15, 7.0, -15), Color(0, 0.8, 0.8), 2.0, 12.0],
		[Vector3(15, 7.0, 15), Color(0.8, 0.2, 0.5), 2.0, 12.0],
		[Vector3(-15, 7.0, 15), Color(0.3, 0.5, 1), 2.0, 12.0],
		[Vector3(15, 7.0, -15), Color(1, 0.5, 0.2), 2.0, 12.0],
		[Vector3(-35, 6.0, -35), Color(0, 1, 0.5), 1.5, 10.0],
		[Vector3(35, 6.0, -35), Color(1, 0.5, 0), 1.5, 10.0],
		[Vector3(-35, 6.0, 35), Color(0, 0.5, 1), 1.5, 10.0],
		[Vector3(35, 6.0, 35), Color(1, 0, 0.3), 1.5, 10.0],
	]
	for ld in light_positions:
		var light = OmniLight3D.new()
		light.position = ld[0]
		light.light_color = ld[1]
		light.light_energy = ld[2]
		light.omni_range = ld[3]
		light.shadow_enabled = false
		parent.add_child(light)

		var fixture = CSGCylinder3D.new()
		fixture.radius = 0.3
		fixture.height = 0.1
		fixture.position = Vector3(ld[0].x, 7.9, ld[0].z)
		var fix_mat = StandardMaterial3D.new()
		fix_mat.albedo_color = ld[1]
		fix_mat.emission_enabled = true
		fix_mat.emission = ld[1]
		fix_mat.emission_energy_multiplier = 2.0
		fixture.material = fix_mat
		parent.add_child(fixture)

func _build_decorations(parent: Node3D):
	for x_off in [-20, -10, 10, 20]:
		var pipe = CSGCylinder3D.new()
		pipe.radius = 0.12
		pipe.height = 80.0
		pipe.position = Vector3(float(x_off), 7.2, 0)
		pipe.rotation_degrees = Vector3(90, 0, 0)
		var pipe_mat = StandardMaterial3D.new()
		pipe_mat.albedo_color = Color(0.1, 0.12, 0.15)
		pipe_mat.metallic = 0.95
		pipe_mat.roughness = 0.15
		pipe.material = pipe_mat
		parent.add_child(pipe)

	for wpos in [
		Vector3(-39.5, 4, -20), Vector3(-39.5, 4, 0), Vector3(-39.5, 4, 20),
		Vector3(39.5, 4, -20), Vector3(39.5, 4, 0), Vector3(39.5, 4, 20),
	]:
		var vpipe = CSGCylinder3D.new()
		vpipe.radius = 0.1
		vpipe.height = 8.0
		vpipe.position = wpos
		var vp_mat = StandardMaterial3D.new()
		vp_mat.albedo_color = Color(0.08, 0.1, 0.14)
		vp_mat.metallic = 0.9
		vp_mat.roughness = 0.2
		vpipe.material = vp_mat
		parent.add_child(vpipe)

	var crate_positions = [
		Vector3(-35, 0.5, 15), Vector3(35, 0.5, -15),
		Vector3(-12, 0.4, -30), Vector3(12, 0.4, 30),
		Vector3(-35, 0.5, -10), Vector3(35, 0.5, 10),
	]
	for cp in crate_positions:
		_add_crate(parent, cp)

	_add_holo_display(parent, Vector3(0, 3.5, -38.5), Vector3(6, 3, 0.05), Color(0, 0.8, 1))
	_add_holo_display(parent, Vector3(0, 3.5, 38.5), Vector3(6, 3, 0.05), Color(1, 0.2, 0.4))

func _add_crate(parent: Node3D, pos: Vector3):
	var crate = CSGBox3D.new()
	crate.size = Vector3(1.2, 1.0, 1.2)
	crate.position = pos
	crate.use_collision = true
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.08, 0.04)
	mat.metallic = 0.6
	mat.roughness = 0.5
	crate.material = mat
	parent.add_child(crate)

	var edge = CSGBox3D.new()
	edge.size = Vector3(1.22, 0.05, 1.22)
	edge.position = Vector3(pos.x, pos.y + 0.5, pos.z)
	var edge_mat = StandardMaterial3D.new()
	edge_mat.albedo_color = Color(0.8, 0.6, 0.1)
	edge_mat.emission_enabled = true
	edge_mat.emission = Color(0.8, 0.5, 0)
	edge_mat.emission_energy_multiplier = 1.5
	edge.material = edge_mat
	parent.add_child(edge)

func _add_holo_display(parent: Node3D, pos: Vector3, size: Vector3, color: Color):
	var display = CSGBox3D.new()
	display.size = size
	display.position = pos
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, 0.3)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	display.material = mat
	parent.add_child(display)

	var frame = CSGBox3D.new()
	frame.size = Vector3(size.x + 0.2, size.y + 0.2, 0.08)
	var frame_z = pos.z - 0.03 if pos.z < 0 else pos.z + 0.03
	frame.position = Vector3(pos.x, pos.y, frame_z)
	var frame_mat = StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.06, 0.08, 0.12)
	frame_mat.metallic = 0.9
	frame_mat.roughness = 0.1
	frame.material = frame_mat
	parent.add_child(frame)

func _add_floor_line(parent: Node3D, pos: Vector3, size: Vector3, color: Color):
	var line = CSGBox3D.new()
	line.size = size
	line.position = pos
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = Color(color.r, color.g, color.b, 1.0)
	mat.emission_energy_multiplier = 1.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	line.material = mat
	parent.add_child(line)

func _add_beam(parent: Node3D, pos: Vector3, size: Vector3, color: Color):
	var beam = CSGBox3D.new()
	beam.size = size
	beam.position = pos
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.8
	mat.roughness = 0.3
	beam.material = mat
	parent.add_child(beam)

func _add_detail_wall(parent: Node3D, pos: Vector3, size: Vector3):
	var wall = CSGBox3D.new()
	wall.size = size
	wall.position = pos
	wall.use_collision = true
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.07, 0.1)
	mat.metallic = 0.9
	mat.roughness = 0.2
	wall.material = mat
	parent.add_child(wall)

func _add_wall_panel(parent: Node3D, pos: Vector3, size: Vector3, color: Color):
	var panel = CSGBox3D.new()
	panel.size = size
	panel.position = pos
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.85
	mat.roughness = 0.3
	panel.material = mat
	parent.add_child(panel)

func _add_neon_line(parent: Node3D, pos: Vector3, size: Vector3, color: Color):
	var neon = CSGBox3D.new()
	neon.size = size
	neon.position = pos
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 4.0
	neon.material = mat
	parent.add_child(neon)

func _make_wall_mat() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.07, 0.1)
	mat.metallic = 0.9
	mat.roughness = 0.2
	return mat

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

	# Detailed weapon model
	var weapon_root = Node3D.new()
	weapon_root.name = "WeaponRoot"
	weapon_root.position = Vector3(0.28, -0.18, -0.3)
	pivot.add_child(weapon_root)

	# Barrel
	var barrel = MeshInstance3D.new()
	barrel.name = "WeaponBarrel"
	var barrel_mesh = BoxMesh.new()
	barrel_mesh.size = Vector3(0.04, 0.05, 0.45)
	barrel.mesh = barrel_mesh
	var barrel_mat = StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.15, 0.18, 0.22)
	barrel_mat.metallic = 0.95
	barrel_mat.roughness = 0.1
	barrel.material_override = barrel_mat
	weapon_root.add_child(barrel)

	# Receiver
	var receiver = MeshInstance3D.new()
	receiver.name = "WeaponReceiver"
	var rec_mesh = BoxMesh.new()
	rec_mesh.size = Vector3(0.06, 0.08, 0.2)
	receiver.mesh = rec_mesh
	receiver.position = Vector3(0, 0, 0.1)
	var rec_mat = StandardMaterial3D.new()
	rec_mat.albedo_color = Color(0.1, 0.12, 0.16)
	rec_mat.metallic = 0.9
	rec_mat.roughness = 0.15
	receiver.material_override = rec_mat
	weapon_root.add_child(receiver)

	# Grip
	var grip = MeshInstance3D.new()
	grip.name = "WeaponGrip"
	var grip_mesh = BoxMesh.new()
	grip_mesh.size = Vector3(0.035, 0.1, 0.04)
	grip.mesh = grip_mesh
	grip.position = Vector3(0, -0.07, 0.12)
	grip.rotation_degrees = Vector3(15, 0, 0)
	grip.material_override = rec_mat
	weapon_root.add_child(grip)

	# Sight
	var sight = MeshInstance3D.new()
	sight.name = "WeaponSight"
	var sight_mesh = BoxMesh.new()
	sight_mesh.size = Vector3(0.02, 0.03, 0.06)
	sight.mesh = sight_mesh
	sight.position = Vector3(0, 0.04, 0.0)
	var sight_mat = StandardMaterial3D.new()
	sight_mat.albedo_color = Color(0.05, 0.05, 0.05)
	sight_mat.metallic = 0.95
	sight_mat.roughness = 0.05
	sight.material_override = sight_mat
	weapon_root.add_child(sight)

	# Accent light on weapon
	var accent = MeshInstance3D.new()
	accent.name = "WeaponAccent"
	var accent_mesh = BoxMesh.new()
	accent_mesh.size = Vector3(0.065, 0.015, 0.15)
	accent.mesh = accent_mesh
	accent.position = Vector3(0, -0.025, 0.02)
	var accent_mat = StandardMaterial3D.new()
	accent_mat.albedo_color = Color(0, 0.8, 1)
	accent_mat.emission_enabled = true
	accent_mat.emission = Color(0, 0.8, 1)
	accent_mat.emission_energy_multiplier = 2.5
	accent.material_override = accent_mat
	weapon_root.add_child(accent)

	# WeaponMesh kept for player.gd compatibility
	var weapon_mesh = MeshInstance3D.new()
	weapon_mesh.name = "WeaponMesh"
	weapon_mesh.visible = false
	pivot.add_child(weapon_mesh)

	var muzzle = Node3D.new()
	muzzle.name = "MuzzlePoint"
	muzzle.position = Vector3(0.28, -0.15, -0.55)
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

	var robot_root = Node3D.new()
	robot_root.name = "RobotModel"
	enemy.add_child(robot_root)

	# Torso material
	var torso_mat = StandardMaterial3D.new()
	torso_mat.albedo_color = Color(0.6, 0.1, 0.1)
	torso_mat.metallic = 0.85
	torso_mat.roughness = 0.2
	torso_mat.emission_enabled = true
	torso_mat.emission = Color(0.8, 0.1, 0.15)
	torso_mat.emission_energy_multiplier = 0.5

	# Main torso
	var torso = MeshInstance3D.new()
	torso.name = "Body"
	var torso_mesh = BoxMesh.new()
	torso_mesh.size = Vector3(0.6, 0.7, 0.4)
	torso.mesh = torso_mesh
	torso.position = Vector3(0, 1.1, 0)
	torso.material_override = torso_mat
	robot_root.add_child(torso)

	# Chest plate
	var chest = MeshInstance3D.new()
	var chest_mesh = BoxMesh.new()
	chest_mesh.size = Vector3(0.5, 0.5, 0.1)
	chest.mesh = chest_mesh
	chest.position = Vector3(0, 1.15, -0.2)
	var chest_mat = StandardMaterial3D.new()
	chest_mat.albedo_color = Color(0.3, 0.05, 0.05)
	chest_mat.metallic = 0.95
	chest_mat.roughness = 0.1
	chest.material_override = chest_mat
	robot_root.add_child(chest)

	# Chest neon accent
	var chest_neon = MeshInstance3D.new()
	var cn_mesh = BoxMesh.new()
	cn_mesh.size = Vector3(0.3, 0.06, 0.11)
	chest_neon.mesh = cn_mesh
	chest_neon.position = Vector3(0, 1.2, -0.21)
	var cn_mat = StandardMaterial3D.new()
	cn_mat.albedo_color = Color(1, 0.1, 0.2)
	cn_mat.emission_enabled = true
	cn_mat.emission = Color(1, 0.1, 0.2)
	cn_mat.emission_energy_multiplier = 3.0
	chest_neon.material_override = cn_mat
	robot_root.add_child(chest_neon)

	# Head
	var head = MeshInstance3D.new()
	head.name = "Head"
	var head_mesh = BoxMesh.new()
	head_mesh.size = Vector3(0.35, 0.3, 0.35)
	head.mesh = head_mesh
	head.position = Vector3(0, 1.65, 0)
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.15, 0.15, 0.18)
	head_mat.metallic = 0.9
	head_mat.roughness = 0.15
	head.material_override = head_mat
	robot_root.add_child(head)

	# Visor
	var visor = MeshInstance3D.new()
	var visor_mesh = BoxMesh.new()
	visor_mesh.size = Vector3(0.3, 0.1, 0.05)
	visor.mesh = visor_mesh
	visor.position = Vector3(0, 1.7, -0.17)
	var visor_mat = StandardMaterial3D.new()
	visor_mat.albedo_color = Color(1, 0.1, 0.1)
	visor_mat.emission_enabled = true
	visor_mat.emission = Color(1, 0.1, 0.15)
	visor_mat.emission_energy_multiplier = 4.0
	visor.material_override = visor_mat
	robot_root.add_child(visor)

	# Shoulder armor
	for x_off in [-0.42, 0.42]:
		var shoulder = MeshInstance3D.new()
		var sh_mesh = BoxMesh.new()
		sh_mesh.size = Vector3(0.22, 0.15, 0.3)
		shoulder.mesh = sh_mesh
		shoulder.position = Vector3(x_off, 1.35, 0)
		var sh_mat = StandardMaterial3D.new()
		sh_mat.albedo_color = Color(0.4, 0.08, 0.08)
		sh_mat.metallic = 0.9
		sh_mat.roughness = 0.15
		shoulder.material_override = sh_mat
		robot_root.add_child(shoulder)

	# Arms
	for x_off in [-0.42, 0.42]:
		var arm = MeshInstance3D.new()
		var arm_mesh = BoxMesh.new()
		arm_mesh.size = Vector3(0.12, 0.5, 0.12)
		arm.mesh = arm_mesh
		arm.position = Vector3(x_off, 0.9, 0)
		arm.material_override = torso_mat
		robot_root.add_child(arm)

	# Legs
	var leg_mat = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.12, 0.12, 0.15)
	leg_mat.metallic = 0.85
	leg_mat.roughness = 0.25
	for x_off in [-0.15, 0.15]:
		var leg = MeshInstance3D.new()
		var leg_mesh = BoxMesh.new()
		leg_mesh.size = Vector3(0.15, 0.6, 0.15)
		leg.mesh = leg_mesh
		leg.position = Vector3(x_off, 0.3, 0)
		leg.material_override = leg_mat
		robot_root.add_child(leg)

	# Feet
	var foot_mat = StandardMaterial3D.new()
	foot_mat.albedo_color = Color(0.08, 0.08, 0.1)
	foot_mat.metallic = 0.9
	foot_mat.roughness = 0.2
	for x_off in [-0.15, 0.15]:
		var foot = MeshInstance3D.new()
		var foot_mesh = BoxMesh.new()
		foot_mesh.size = Vector3(0.18, 0.1, 0.25)
		foot.mesh = foot_mesh
		foot.position = Vector3(x_off, 0.05, -0.03)
		foot.material_override = foot_mat
		robot_root.add_child(foot)

	# Enemy glow light
	var elight = OmniLight3D.new()
	elight.light_color = Color(1, 0.1, 0.15)
	elight.light_energy = 1.0
	elight.omni_range = 4.0
	elight.position = Vector3(0, 1.2, 0)
	elight.shadow_enabled = false
	robot_root.add_child(elight)

	enemy.set_script(load("res://scripts/enemy_bot.gd"))
	add_child(enemy)

func _create_hud():
	var hud = CanvasLayer.new()
	hud.name = "HUD"
	hud.set_script(load("res://scripts/hud_overlay.gd"))
	add_child(hud)
