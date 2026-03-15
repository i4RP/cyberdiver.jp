extends Node3D

## Creates visual weapon models for the FPS view

var current_weapon_mesh: MeshInstance3D = null


func _ready() -> void:
	_create_weapon_visual("Handgun")


func update_weapon(weapon_name: String) -> void:
	_create_weapon_visual(weapon_name)


func _create_weapon_visual(weapon_name: String) -> void:
	# Remove old mesh
	if current_weapon_mesh:
		current_weapon_mesh.queue_free()

	current_weapon_mesh = MeshInstance3D.new()

	match weapon_name:
		"Handgun":
			_build_handgun(current_weapon_mesh)
		"Cyber Rifle":
			_build_rifle(current_weapon_mesh)
		"Sniper Rifle":
			_build_sniper(current_weapon_mesh)
		_:
			_build_handgun(current_weapon_mesh)

	add_child(current_weapon_mesh)


func _build_handgun(mesh_instance: MeshInstance3D) -> void:
	var box := BoxMesh.new()
	box.size = Vector3(0.06, 0.12, 0.25)
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0, 0, 0)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.25)
	mat.metallic = 0.8
	mat.roughness = 0.2
	mesh_instance.material_override = mat

	# Barrel
	var barrel := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.015
	cyl.bottom_radius = 0.015
	cyl.height = 0.15
	barrel.mesh = cyl
	barrel.position = Vector3(0, 0.03, -0.18)
	barrel.rotation_degrees.x = 90

	var barrel_mat := StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.15, 0.15, 0.2)
	barrel_mat.metallic = 0.9
	barrel.material_override = barrel_mat
	mesh_instance.add_child(barrel)


func _build_rifle(mesh_instance: MeshInstance3D) -> void:
	var box := BoxMesh.new()
	box.size = Vector3(0.06, 0.1, 0.5)
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0, 0, -0.05)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.2, 0.25)
	mat.metallic = 0.7
	mat.roughness = 0.3
	mat.emission_enabled = true
	mat.emission = Color(0.0, 0.3, 0.4)
	mat.emission_energy_multiplier = 0.5
	mesh_instance.material_override = mat

	# Barrel
	var barrel := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.02
	cyl.bottom_radius = 0.018
	cyl.height = 0.2
	barrel.mesh = cyl
	barrel.position = Vector3(0, 0.02, -0.33)
	barrel.rotation_degrees.x = 90

	var barrel_mat := StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.1, 0.1, 0.15)
	barrel_mat.metallic = 0.9
	barrel.material_override = barrel_mat
	mesh_instance.add_child(barrel)

	# Stock
	var stock := MeshInstance3D.new()
	var stock_box := BoxMesh.new()
	stock_box.size = Vector3(0.05, 0.08, 0.15)
	stock.mesh = stock_box
	stock.position = Vector3(0, -0.02, 0.28)

	var stock_mat := StandardMaterial3D.new()
	stock_mat.albedo_color = Color(0.12, 0.12, 0.15)
	stock.material_override = stock_mat
	mesh_instance.add_child(stock)


func _build_sniper(mesh_instance: MeshInstance3D) -> void:
	var box := BoxMesh.new()
	box.size = Vector3(0.05, 0.08, 0.7)
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0, 0, -0.1)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.12, 0.18)
	mat.metallic = 0.85
	mat.roughness = 0.15
	mesh_instance.material_override = mat

	# Scope
	var scope := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.025
	cyl.bottom_radius = 0.025
	cyl.height = 0.12
	scope.mesh = cyl
	scope.position = Vector3(0, 0.07, -0.05)

	var scope_mat := StandardMaterial3D.new()
	scope_mat.albedo_color = Color(0.08, 0.08, 0.12)
	scope_mat.metallic = 0.9
	scope.material_override = scope_mat
	mesh_instance.add_child(scope)

	# Barrel
	var barrel := MeshInstance3D.new()
	var barrel_cyl := CylinderMesh.new()
	barrel_cyl.top_radius = 0.012
	barrel_cyl.bottom_radius = 0.015
	barrel_cyl.height = 0.3
	barrel.mesh = barrel_cyl
	barrel.position = Vector3(0, 0.01, -0.48)
	barrel.rotation_degrees.x = 90

	var barrel_mat := StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.08, 0.08, 0.1)
	barrel_mat.metallic = 0.95
	barrel.material_override = barrel_mat
	mesh_instance.add_child(barrel)
