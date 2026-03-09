extends Area2D
class_name EquipmentPickup

signal equipped(equipment_id: String)

@export var equipment_id: String = ""

var _is_consumed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _is_consumed:
		return
	if not body.is_in_group("player"):
		return
	if equipment_id.is_empty():
		return
	_is_consumed = true
	monitoring = false
	GameState.equip_item(equipment_id)
	emit_signal("equipped", equipment_id)
	queue_free()
