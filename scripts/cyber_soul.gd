extends Area3D

## Cyber Soul - dropped when a player/bot dies, collectible by enemies

const LIFETIME: float = 15.0
const TEAM_LIFE_DAMAGE: int = 3000
const HEAL_AMOUNT: float = 30.0
const BOB_SPEED: float = 3.0
const BOB_HEIGHT: float = 0.3
const ROTATE_SPEED: float = 2.0

var soul_team: int = -1  # Team of the player who died (collecting enemy gets benefit)
var timer: float = LIFETIME
var base_y: float = 0.0
var time_alive: float = 0.0


func _ready() -> void:
	base_y = global_position.y + 1.0
	global_position.y = base_y
	body_entered.connect(_on_body_entered)

	# Create visual
	_create_visual()


func _create_visual() -> void:
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.4
	sphere.height = 0.8
	mesh_instance.mesh = sphere

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 1.0, 0.8, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(0.0, 1.0, 0.8)
	mat.emission_energy_multiplier = 4.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = mat
	add_child(mesh_instance)

	# Add point light
	var light := OmniLight3D.new()
	light.light_color = Color(0.0, 1.0, 0.8)
	light.light_energy = 2.0
	light.omni_range = 5.0
	add_child(light)


func _process(delta: float) -> void:
	timer -= delta
	time_alive += delta

	# Bob animation
	global_position.y = base_y + sin(time_alive * BOB_SPEED) * BOB_HEIGHT

	# Rotate
	rotate_y(ROTATE_SPEED * delta)

	# Fade out near end of life
	if timer <= 3.0:
		var alpha: float = timer / 3.0
		modulate = Color(1, 1, 1, alpha)

	if timer <= 0.0:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if not body.has_method("heal"):
		return

	# Only enemies of the dead player can collect
	var collector_team: int = body.get("team") if body.get("team") != null else -1
	if collector_team == soul_team:
		return  # Can't collect own team's soul

	# Apply effects
	body.heal(HEAL_AMOUNT)
	GameManager.damage_team_life(soul_team, TEAM_LIFE_DAMAGE)
	BattleData.record_soul_collected()

	queue_free()
