extends Node

signal stage_unlocked(stage_id: String)
signal equipment_equipped(equipment_id: String)

const SAVE_PATH := "user://progress.cfg"
const EQUIPMENT_DATA_PATH := "res://data/equipment/equipment.json"
const STAGE_DATA_PATH := "res://data/stages/stages.json"

var equipment_defs: Dictionary = {}
var stage_defs: Dictionary = {}
var unlocked_stages: Dictionary = {}
var cleared_stages: Dictionary = {}
var equipped_item_id: String = ""

func _ready() -> void:
	randomize()
	_load_json_data()
	_load_progress()

func _load_json_data() -> void:
	equipment_defs = _load_json_file(EQUIPMENT_DATA_PATH)
	stage_defs = _load_json_file(STAGE_DATA_PATH)

func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}

func _load_progress() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == OK:
		unlocked_stages = cfg.get_value("progress", "unlocked_stages", {})
		cleared_stages = cfg.get_value("progress", "cleared_stages", {})
		equipped_item_id = String(cfg.get_value("progress", "equipped_item_id", ""))
	if _apply_default_unlocks():
		_save_progress()
	elif err != OK:
		_save_progress()

func _apply_default_unlocks() -> bool:
	var changed := false
	for stage_id: String in stage_defs.keys():
		var config: Dictionary = stage_defs[stage_id]
		if bool(config.get("unlock_on_start", false)) and not bool(unlocked_stages.get(stage_id, false)):
			unlocked_stages[stage_id] = true
			changed = true
	return changed

func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked_stages", unlocked_stages)
	cfg.set_value("progress", "cleared_stages", cleared_stages)
	cfg.set_value("progress", "equipped_item_id", equipped_item_id)
	cfg.save(SAVE_PATH)

func is_stage_unlocked(stage_id: String) -> bool:
	return bool(unlocked_stages.get(stage_id, false))

func is_stage_cleared(stage_id: String) -> bool:
	return bool(cleared_stages.get(stage_id, false))

func unlock_stage(stage_id: String) -> void:
	if is_stage_unlocked(stage_id):
		return
	unlocked_stages[stage_id] = true
	_save_progress()
	emit_signal("stage_unlocked", stage_id)

func mark_stage_cleared(stage_id: String) -> void:
	if is_stage_cleared(stage_id):
		return
	cleared_stages[stage_id] = true
	var stage_config: Dictionary = stage_defs.get(stage_id, {})
	for next_stage: String in stage_config.get("unlock_on_clear", []):
		unlock_stage(next_stage)
	_save_progress()

func get_stage_scene(stage_id: String) -> String:
	var stage_config: Dictionary = stage_defs.get(stage_id, {})
	return String(stage_config.get("scene", ""))

func roll_boss_drop(stage_id: String) -> String:
	var stage_config: Dictionary = stage_defs.get(stage_id, {})
	var pool: Array = stage_config.get("boss_drop_pool", [])
	if pool.is_empty():
		return ""
	return String(pool[randi() % pool.size()])

func equip_item(equipment_id: String) -> void:
	if not equipment_defs.has(equipment_id):
		return
	equipped_item_id = equipment_id
	_save_progress()
	emit_signal("equipment_equipped", equipment_id)

func get_equipped_item() -> Dictionary:
	if equipped_item_id.is_empty() or not equipment_defs.has(equipped_item_id):
		return {}
	return equipment_defs[equipped_item_id]

func get_max_hp_bonus() -> float:
	return float(get_equipped_item().get("max_hp_bonus", 0.0))

func get_damage_multiplier() -> float:
	return float(get_equipped_item().get("damage_multiplier", 1.0))

func get_equipment_name(equipment_id: String) -> String:
	return String(equipment_defs.get(equipment_id, {}).get("name", equipment_id))
