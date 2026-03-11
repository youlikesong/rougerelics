extends EnemyBase
class_name G2Enemy

enum MoveState {
	CHASE,
	WINDUP,
	CHARGE
}

@export var windup_duration: float = 0.5
@export var charge_duration: float = 1.0
@export var charge_start_speed: float = 220.0
@export var charge_end_speed: float = 500.0
@export var charge_cooldown: float = 1.5
@export var charge_trigger_distance: float = 240.0

var _move_state: MoveState = MoveState.CHASE
var _state_timer: float = 0.0
var _charge_cooldown_remaining: float = 0.0
var _locked_charge_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	move_speed = 95.0
	max_hp = 60.0
	touch_damage = 14.0
	attack_cooldown = 0.75
	super._ready()

func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_move_state = MoveState.CHASE
		_state_timer = 0.0
		_locked_charge_direction = Vector2.ZERO
		_reset_movement_state()
		move_and_slide()
		return

	_charge_cooldown_remaining = max(_charge_cooldown_remaining - delta, 0.0)

	match _move_state:
		MoveState.CHASE:
			_process_chase(delta)
		MoveState.WINDUP:
			_process_windup(delta)
		MoveState.CHARGE:
			_process_charge(delta)

func _process_chase(delta: float) -> void:
	var to_target: Vector2 = _target.global_position - global_position
	move_toward_target(delta, move_speed)

	if _charge_cooldown_remaining > 0.0:
		return

	if to_target.length() <= charge_trigger_distance:
		_move_state = MoveState.WINDUP
		_state_timer = windup_duration
		velocity = Vector2.ZERO

func _process_windup(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()

	_state_timer -= delta
	if _state_timer > 0.0:
		return

	_locked_charge_direction = (_target.global_position - global_position).normalized()
	if _locked_charge_direction == Vector2.ZERO:
		_locked_charge_direction = Vector2.DOWN

	_move_state = MoveState.CHARGE
	_state_timer = charge_duration

func _process_charge(delta: float) -> void:
	var safe_charge_duration: float = max(charge_duration, 0.001)
	var progress: float = clampf(1.0 - (_state_timer / safe_charge_duration), 0.0, 1.0)
	var current_speed: float = lerpf(charge_start_speed, charge_end_speed, progress)

	velocity = _locked_charge_direction * current_speed
	move_and_slide()

	_state_timer -= delta
	if _state_timer > 0.0:
		return

	velocity = Vector2.ZERO
	_move_state = MoveState.CHASE
	_charge_cooldown_remaining = charge_cooldown
