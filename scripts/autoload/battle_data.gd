extends Node

## Tracks per-player battle statistics for BP calculation

var damage_dealt: float = 0.0
var damage_taken: float = 0.0
var respawn_count: int = 0
var cyber_souls_collected: int = 0
var cyber_souls_lost: int = 0
var kills: int = 0
var deaths: int = 0
var assists: int = 0
var support_score: float = 0.0
var battle_won: bool = false
var perfect_victory: bool = false
var final_team_life_ally: int = 0
var final_team_life_enemy: int = 0

signal stats_updated()


func reset() -> void:
	damage_dealt = 0.0
	damage_taken = 0.0
	respawn_count = 0
	cyber_souls_collected = 0
	cyber_souls_lost = 0
	kills = 0
	deaths = 0
	assists = 0
	support_score = 0.0
	battle_won = false
	perfect_victory = false
	final_team_life_ally = 0
	final_team_life_enemy = 0


func record_damage_dealt(amount: float) -> void:
	damage_dealt += amount
	stats_updated.emit()


func record_damage_taken(amount: float) -> void:
	damage_taken += amount
	stats_updated.emit()


func record_kill() -> void:
	kills += 1
	stats_updated.emit()


func record_death() -> void:
	deaths += 1
	respawn_count += 1
	stats_updated.emit()


func record_soul_collected() -> void:
	cyber_souls_collected += 1
	stats_updated.emit()


func record_soul_lost() -> void:
	cyber_souls_lost += 1
	stats_updated.emit()


func finalize(won: bool, perfect: bool, ally_life: int, enemy_life: int) -> void:
	battle_won = won
	perfect_victory = perfect
	final_team_life_ally = ally_life
	final_team_life_enemy = enemy_life


func calculate_battle_points() -> int:
	var bp: float = 0.0

	# Damage contribution
	bp += damage_dealt * 0.1

	# Survival bonus (less damage taken = more BP)
	bp += maxf(0.0, 1000.0 - damage_taken * 0.05)

	# Kill/Death
	bp += kills * 200.0
	bp -= deaths * 50.0

	# Cyber Souls
	bp += cyber_souls_collected * 500.0
	bp -= cyber_souls_lost * 100.0

	# Win bonus
	if battle_won:
		bp += 1000.0

	# Perfect victory bonus
	if perfect_victory:
		bp += 2000.0

	# Team life differential
	var life_diff: float = float(final_team_life_ally - final_team_life_enemy)
	bp += life_diff * 0.01

	# Support bonus
	bp += support_score * 0.5

	# Respawn penalty
	bp -= respawn_count * 30.0

	return maxi(0, int(bp))
