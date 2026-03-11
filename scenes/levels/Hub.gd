extends Control

@onready var stage_1_1_button: Button = $CenterContainer/VBoxContainer/Stage11Button
@onready var stage_1_2_button: Button = $CenterContainer/VBoxContainer/Stage12Button
@onready var stage_1_2_status: Label = $CenterContainer/VBoxContainer/Stage12Status
@onready var equipment_label: Label = $CenterContainer/VBoxContainer/EquipmentLabel

func _ready() -> void:
	stage_1_1_button.disabled = not GameState.is_stage_unlocked("1-1")
	stage_1_2_button.disabled = not GameState.is_stage_unlocked("1-2")
	stage_1_1_button.pressed.connect(_on_stage_1_1_pressed)
	stage_1_2_button.pressed.connect(_on_stage_1_2_pressed)
	_update_ui()

func _update_ui() -> void:
	var equipped_item := GameState.get_equipped_item()
	if equipped_item.is_empty():
		equipment_label.text = "Equipped: None"
	else:
		equipment_label.text = "Equipped: %s" % String(equipped_item.get("name", "Unknown"))
	stage_1_1_button.disabled = not GameState.is_stage_unlocked("1-1")
	stage_1_2_button.disabled = not GameState.is_stage_unlocked("1-2")
	stage_1_2_status.text = "Stage 1-2 unlocked: %s" % ("Yes" if GameState.is_stage_unlocked("1-2") else "No")

func _on_stage_1_1_pressed() -> void:
	_enter_stage("1-1")

func _on_stage_1_2_pressed() -> void:
	_enter_stage("1-2")

func _enter_stage(stage_id: String) -> void:
	var stage_scene_path := GameState.get_stage_scene(stage_id)
	if stage_scene_path.is_empty():
		return
	get_tree().change_scene_to_file(stage_scene_path)
