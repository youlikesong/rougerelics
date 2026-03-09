extends Node
class_name PlayerStats

signal hp_changed(current_hp: float, max_hp: float)
signal died

@export var base_max_hp: float = 100.0

var max_hp: float = 0.0
var hp: float = 0.0

func _ready() -> void:
	recalculate_max_hp()
	hp = max_hp
	emit_signal("hp_changed", hp, max_hp)

func recalculate_max_hp() -> void:
	max_hp = base_max_hp + GameState.get_max_hp_bonus()
	hp = min(hp, max_hp) if hp > 0.0 else max_hp
	emit_signal("hp_changed", hp, max_hp)

func apply_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp = max(hp - amount, 0.0)
	emit_signal("hp_changed", hp, max_hp)
	if hp <= 0.0:
		emit_signal("died")

func heal_full() -> void:
	hp = max_hp
	emit_signal("hp_changed", hp, max_hp)
