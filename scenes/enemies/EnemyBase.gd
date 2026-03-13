extends CharacterBody2D
class_name EnemyBase

signal died(enemy: EnemyBase)

@export var move_speed: float = 120.0
@export var max_hp: float = 40.0
@export var touch_damage: float = 10.0
@export var attack_cooldown: float = 0.8
@export var chase_stop_distance: float = 32.0
@export var chase_separation_distance: float = 22.0
@export var separation_speed_multiplier: float = 0.4

var _current_hp: float = 0.0
var _target: Node2D
var _can_attack: bool = true
var _navigation_agent: NavigationAgent2D

func _ready() -> void:
	_current_hp = max_hp
	_navigation_agent = get_node_or_null("NavigationAgent2D") as NavigationAgent2D

	var hitbox := $HitBox as Area2D
	if hitbox != null:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func set_target(target: Node2D) -> void:
	_target = target

func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_reset_movement_state()
		move_and_slide()
		return

	move_toward_target(delta)

func move_toward_target(delta: float, speed: float = -1.0) -> void:
	if _target == null or not is_instance_valid(_target):
		_reset_movement_state()
		move_and_slide()
		return

	if speed < 0.0:
		speed = move_speed

	var to_target: Vector2 = _target.global_position - global_position
	var distance_to_target: float = to_target.length()
	if distance_to_target <= chase_separation_distance:
		var separation_direction := (-to_target).normalized()
		if separation_direction == Vector2.ZERO:
			separation_direction = Vector2.DOWN
		velocity = separation_direction * (speed * separation_speed_multiplier)
		move_and_slide()
		return
	if distance_to_target <= chase_stop_distance:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var chase_direction: Vector2 = _get_chase_direction(to_target)
	velocity = chase_direction * speed
	move_and_slide()

func _get_chase_direction(to_target: Vector2) -> Vector2:
	if _navigation_agent == null:
		return to_target.normalized()

	var navigation_map: RID = _navigation_agent.get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(navigation_map) == 0:
		return to_target.normalized()

	_navigation_agent.target_position = _target.global_position

	if _navigation_agent.is_navigation_finished():
		return to_target.normalized()

	var next_path_position: Vector2 = _navigation_agent.get_next_path_position()
	var path_direction: Vector2 = next_path_position - global_position
	return path_direction.normalized() if path_direction != Vector2.ZERO else to_target.normalized()

func _reset_movement_state() -> void:
	velocity = Vector2.ZERO
	if _navigation_agent != null:
		_navigation_agent.target_position = global_position

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

		var timer: SceneTreeTimer = get_tree().create_timer(attack_cooldown)
		timer.timeout.connect(func() -> void:
			_can_attack = true
		)
