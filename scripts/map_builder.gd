extends Node3D

## Procedural map material and detail builder
## Attaches sci-fi materials to CSG geometry at runtime

const FLOOR_COLOR := Color(0.08, 0.08, 0.12)
const WALL_COLOR := Color(0.1, 0.12, 0.18)
const COVER_COLOR := Color(0.12, 0.14, 0.2)
const BUILDING_COLOR := Color(0.06, 0.08, 0.14)
const EMISSION_COLOR := Color(0.0, 0.8, 0.7)

var floor_mat: StandardMaterial3D
var wall_mat: StandardMaterial3D
var cover_mat: StandardMaterial3D
var building_mat: StandardMaterial3D


func _ready() -> void:
	_create_materials()
	_apply_materials()
	_add_neon_strips()
	_add_gate_markers()


func _create_materials() -> void:
	floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = FLOOR_COLOR
	floor_mat.metallic = 0.6
	floor_mat.roughness = 0.3

	wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = WALL_COLOR
	wall_mat.metallic = 0.7
	wall_mat.roughness = 0.2

	cover_mat = StandardMaterial3D.new()
	cover_mat.albedo_color = COVER_COLOR
	cover_mat.metallic = 0.5
	cover_mat.roughness = 0.4

	building_mat = StandardMaterial3D.new()
	building_mat.albedo_color = BUILDING_COLOR
	building_mat.metallic = 0.8
	building_mat.roughness = 0.15


func _apply_materials() -> void:
	var map_geo := get_parent().get_node_or_null("MapGeometry")
	if not map_geo:
		return

	for child in map_geo.get_children():
		if child is CSGBox3D:
			var child_name: String = child.name
			if "Floor" in child_name:
				child.material = floor_mat
			elif "Wall" in child_name:
				child.material = wall_mat
			elif "Cover" in child_name or "Ramp" in child_name:
				child.material = cover_mat
			elif "Building" in child_name:
				child.material = building_mat


func _add_neon_strips() -> void:
	# Add glowing neon strips along walls for cyberpunk feel
	var positions: Array[Vector3] = [
		Vector3(-39.5, 1.0, -20), Vector3(-39.5, 1.0, 0), Vector3(-39.5, 1.0, 20),
		Vector3(39.5, 1.0, -20), Vector3(39.5, 1.0, 0), Vector3(39.5, 1.0, 20),
		Vector3(-20, 1.0, -49.5), Vector3(0, 1.0, -49.5), Vector3(20, 1.0, -49.5),
		Vector3(-20, 1.0, 49.5), Vector3(0, 1.0, 49.5), Vector3(20, 1.0, 49.5),
	]

	for pos in positions:
		var strip := MeshInstance3D.new()
		var box := BoxMesh.new()

		if absf(pos.x) > 39.0:
			# Vertical wall strips (along Z)
			box.size = Vector3(0.05, 0.3, 8.0)
		else:
			# Horizontal wall strips (along X)
			box.size = Vector3(8.0, 0.3, 0.05)

		strip.mesh = box
		strip.global_position = pos

		var mat := StandardMaterial3D.new()
		mat.albedo_color = EMISSION_COLOR
		mat.emission_enabled = true
		mat.emission = EMISSION_COLOR
		mat.emission_energy_multiplier = 3.0
		strip.material_override = mat

		get_parent().add_child(strip)


func _add_gate_markers() -> void:
	# Add visual markers at spawn gates
	var alpha_gates := get_parent().get_node_or_null("SpawnPointsAlpha")
	var bravo_gates := get_parent().get_node_or_null("SpawnPointsBravo")

	if alpha_gates:
		var gate_names := ["A", "B", "C", "D", "E"]
		var idx := 0
		for gate in alpha_gates.get_children():
			_create_gate_visual(gate.global_position, gate_names[idx], Color(0.0, 0.5, 1.0))
			idx += 1

	if bravo_gates:
		var gate_names := ["A", "B", "C", "D", "E"]
		var idx := 0
		for gate in bravo_gates.get_children():
			_create_gate_visual(gate.global_position, gate_names[idx], Color(1.0, 0.2, 0.1))
			idx += 1


func _create_gate_visual(pos: Vector3, gate_label: String, color: Color) -> void:
	# Gate pillar
	var pillar := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.0, 4.0, 0.5)
	pillar.mesh = box
	pillar.global_position = pos + Vector3(0, 2, 0)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color * 0.3
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.5
	pillar.material_override = mat
	get_parent().add_child(pillar)

	# Gate light
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 2.0
	light.omni_range = 6.0
	light.global_position = pos + Vector3(0, 3.5, 0)
	get_parent().add_child(light)

	# Gate label (3D text)
	var label := Label3D.new()
	label.text = "GATE %s" % gate_label
	label.font_size = 48
	label.modulate = color
	label.global_position = pos + Vector3(0, 4.5, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	get_parent().add_child(label)
