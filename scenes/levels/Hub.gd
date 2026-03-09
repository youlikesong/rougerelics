extends Control

@onready var stage_1_1_button: Button = $CenterContainer/VBoxContainer/Stage11Button
@onready var stage_1_2_status: Label = $CenterContainer/VBoxContainer/Stage12Status
@onready var equipment_label: Label = $CenterContainer/VBoxContainer/EquipmentLabel

func _ready() -> void:
	stage_1_1_button.disabled = not GameState.is_stage_unlocked("1-1")
	stage_1_1_button.pressed.connect(_on_stage_1_1_pressed)
	_update_ui()

func _update_ui() -> void:
	var equipped_item := GameState.get_equipped_item()
	if equipped_item.is_empty():
		equipment_label.text = "Equipped: None"
	else:
		equipment_label.text = "Equipped: %s" % String(equipped_item.get("name", "Unknown"))
	stage_1_2_status.text = "Stage 1-2 unlocked: %s" % ("Yes" if GameState.is_stage_unlocked("1-2") else "No")
	
func _on_stage_1_1_pressed() -> void:
	print("Stage 1-1 button pressed")
	get_tree().change_scene_to_file("res://scenes/levels/Stage1_1.tscn")