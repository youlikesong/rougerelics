extends EnemyBase
class_name G3Enemy

const ENEMY_PROJECTILE_SCENE := preload("res://scenes/weapons/EnemyProjectile.tscn")

enum MoveState {
	MOVE,
	AIM
}

@export var preferred_distance: float = 340.0
@export var retreat_distance: float = 185.0
@export var attack_range: float = 460.0
@export var retreat_speed_multiplier: float = 1.2
@export var aim_duration: float = 0.35
@export var shoot_cooldown: float = 1.3

var _move_state: MoveState = MoveState.MOVE
var _state_timer: float = 0.0
var _shoot_cooldown_remaining: float = 0.0
var _locked_shot_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	move_speed = 85.0
	max_hp = 45.0
	touch_damage = 8.0
	attack_cooldown = 1.0
	super._ready()

func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_move_state = MoveState.MOVE
		_state_timer = 0.0
		_locked_shot_direction = Vector2.ZERO
		_shoot_cooldown_remaining = 0.0
		_reset_movement_state()
		move_and_slide()
		return

	_shoot_cooldown_remaining = max(_shoot_cooldown_remaining - delta, 0.0)

	match _move_state:
		MoveState.MOVE:
			_process_move(delta)
		MoveState.AIM:
			_process_aim(delta)

func _process_move(delta: float) -> void:
	var to_target: Vector2 = _target.global_position - global_position
	var distance_to_target := to_target.length()

	if distance_to_target <= retreat_distance:
		var retreat_direction := (-to_target).normalized()
		if retreat_direction == Vector2.ZERO:
			retreat_direction = Vector2.DOWN
		velocity = retreat_direction * (move_speed * retreat_speed_multiplier)
		move_and_slide()
		return

	if distance_to_target > preferred_distance:
		move_toward_target(delta, move_speed)
	else:
		velocity = Vector2.ZERO
		move_and_slide()

	if _shoot_cooldown_remaining > 0.0:
		return

	if distance_to_target <= attack_range:
		_move_state = MoveState.AIM
		_state_timer = aim_duration
		_locked_shot_direction = to_target.normalized()
		if _locked_shot_direction == Vector2.ZERO:
			_locked_shot_direction = Vector2.DOWN
		velocity = Vector2.ZERO

func _process_aim(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()

	_state_timer -= delta
	if _state_timer > 0.0:
		return

	_fire_projectile()
	_move_state = MoveState.MOVE
	_shoot_cooldown_remaining = shoot_cooldown

func _fire_projectile() -> void:
	var projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
	if projectile == null:
		return

	projectile.global_position = global_position
	projectile.direction = _locked_shot_direction
	get_tree().current_scene.add_child(projectile)
