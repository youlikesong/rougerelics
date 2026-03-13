extends Area2D
class_name EnemyProjectile

@export var speed: float = 280.0
@export var damage: float = 12.0
@export var lifetime: float = 2.2

var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	direction = direction.normalized()
	body_entered.connect(_on_body_entered)
	var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("apply_damage"):
		body.apply_damage(damage)
		queue_free()
		return
