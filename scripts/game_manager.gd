extends Node

# Team life
var team_life_alpha: int = 100000
var team_life_beta: int = 100000

# Battle
var battle_time: float = 300.0
var is_battle_active: bool = false

# Player stats
var player_hp: int = 100
var player_max_hp: int = 100
var player_kills: int = 0
var player_deaths: int = 0
var player_damage_dealt: float = 0.0
var souls_collected: int = 0

# Weapons
var current_weapon: int = 0
var weapons: Array = []

signal weapon_changed(index: int)
signal player_died()
signal battle_ended()

func _ready():
	weapons = [
		{
			"name": "Handgun",
			"damage": 25,
			"fire_rate": 0.4,
			"reload_time": 1.5,
			"mag_size": 12,
			"current_ammo": 12,
			"spread": 0.01,
		},
		{
			"name": "Cyber Rifle",
			"damage": 15,
			"fire_rate": 0.1,
			"reload_time": 2.0,
			"mag_size": 30,
			"current_ammo": 30,
			"spread": 0.04,
		},
		{
			"name": "Sniper",
			"damage": 80,
			"fire_rate": 1.2,
			"reload_time": 2.5,
			"mag_size": 5,
			"current_ammo": 5,
			"spread": 0.002,
		},
	]

func start_battle():
	team_life_alpha = 100000
	team_life_beta = 100000
	battle_time = 300.0
	is_battle_active = true
	player_hp = player_max_hp
	player_kills = 0
	player_deaths = 0
	player_damage_dealt = 0.0
	souls_collected = 0
	for w in weapons:
		w["current_ammo"] = w["mag_size"]

func get_weapon() -> Dictionary:
	if current_weapon >= 0 and current_weapon < weapons.size():
		return weapons[current_weapon]
	return weapons[0]

func next_weapon():
	current_weapon = (current_weapon + 1) % weapons.size()
	weapon_changed.emit(current_weapon)

func reload_weapon():
	var w = weapons[current_weapon]
	w["current_ammo"] = w["mag_size"]

func fire_weapon() -> bool:
	var w = weapons[current_weapon]
	if w["current_ammo"] > 0:
		w["current_ammo"] -= 1
		return true
	return false

func damage_player(amount: int):
	player_hp -= amount
	if player_hp <= 0:
		player_hp = 0
		player_deaths += 1
		player_died.emit()

func _process(delta):
	if is_battle_active:
		battle_time -= delta
		if battle_time <= 0:
			battle_time = 0
			is_battle_active = false
			battle_ended.emit()
