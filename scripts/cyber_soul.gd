extends Area3D

var lifetime: float = 15.0
var bob_time: float = 0.0
var start_y: float = 0.0
var collected: bool = false

func _ready():
	start_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float):
	if collected:
		return

	# Bobbing animation
	bob_time += delta * 3.0
	position.y = start_y + sin(bob_time) * 0.2

	# Rotate
	rotate_y(delta * 2.0)

	# Lifetime
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

	# Fade out in last 3 seconds
	if lifetime < 3.0:
		var mesh = get_child(1) if get_child_count() > 1 else null
		if mesh and mesh is MeshInstance3D and mesh.material_override:
			var mat = mesh.material_override as StandardMaterial3D
			if mat:
				mat.albedo_color.a = lifetime / 3.0

func _on_body_entered(body: Node3D):
	if collected:
		return
	if body.name == "Player":
		collected = true
		GameManager.souls_collected += 1
		GameManager.team_life_beta -= 5000
		GameManager.player_hp = mini(GameManager.player_hp + 20, GameManager.player_max_hp)
		queue_free()
