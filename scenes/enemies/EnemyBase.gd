extends CharacterBody2D
class_name EnemyBase

signal died(enemy: EnemyBase)

@export var move_speed: float = 120.0
@export var max_hp: float = 40.0
@export var touch_damage: float = 10.0
@export var attack_cooldown: float = 0.8

var _current_hp: float = 0.0
var _target: Node2D
var _can_attack: bool = true

func _ready() -> void:
	_current_hp = max_hp
	var hitbox := $HitBox as Area2D
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func set_target(target: Node2D) -> void:
	_target = target

func _physics_process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var to_target := _target.global_position - global_position
	velocity = to_target.normalized() * move_speed
	move_and_slide()

func take_damage(amount: float) -> void:
	_current_hp -= amount
	if _current_hp <= 0.0:
		emit_signal("died", self)
		queue_free()

func _on_hitbox_body_entered(body: Node) -> void:
	if not _can_attack:
		return
	if body.has_method("apply_damage"):
		body.apply_damage(touch_damage)
		_can_attack = false
		var timer := get_tree().create_timer(attack_cooldown)
		timer.timeout.connect(func() -> void:
			_can_attack = true
		)
