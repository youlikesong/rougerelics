extends CanvasLayer
class_name StageHUD

@onready var hp_label: Label = $MarginContainer/VBoxContainer/HpLabel
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel

func set_hp(current_hp: float, max_hp: float) -> void:
	hp_label.text = "HP: %d / %d" % [int(current_hp), int(max_hp)]

func set_status(text: String) -> void:
	status_label.text = text
