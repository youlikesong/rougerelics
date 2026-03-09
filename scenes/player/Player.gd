extends CharacterBody2D
class_name PlayerCharacter

signal hp_changed(current_hp: float, max_hp: float)
signal died

@export var move_speed: float = 260.0
@export var shoot_cooldown: float = 0.2
@export var base_projectile_damage: float = 20.0

const PROJECTILE_SCENE := preload("res://scenes/weapons/Projectile.tscn")

@onready var _muzzle: Marker2D = $Muzzle
@onready var _stats: PlayerStats = $Stats

var _last_aim: Vector2 = Vector2.RIGHT
var _shoot_timer: float = 0.0

func _ready() -> void:
	_stats.hp_changed.connect(_on_hp_changed)
	_stats.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	_handle_movement()
	_handle_shooting(delta)

func _handle_movement() -> void:
	var input_dir := _read_wasd_vector()
	velocity = input_dir * move_speed
	if input_dir != Vector2.ZERO:
		_last_aim = input_dir.normalized()
	move_and_slide()

func _handle_shooting(delta: float) -> void:
	_shoot_timer = max(_shoot_timer - delta, 0.0)
	var shoot_dir := _read_arrow_vector()
	if shoot_dir != Vector2.ZERO:
		_last_aim = shoot_dir.normalized()
	if _shoot_timer > 0.0:
		return
	if shoot_dir != Vector2.ZERO:
		_fire_projectile(_last_aim)
		_shoot_timer = shoot_cooldown

func _read_wasd_vector() -> Vector2:
	var x := 0.0
	var y := 0.0
	if Input.is_physical_key_pressed(KEY_A):
		x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		y += 1.0
	var result := Vector2(x, y)
	return result.normalized() if result != Vector2.ZERO else Vector2.ZERO

func _read_arrow_vector() -> Vector2:
	var x := 0.0
	var y := 0.0
	if Input.is_physical_key_pressed(KEY_LEFT):
		x -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT):
		x += 1.0
	if Input.is_physical_key_pressed(KEY_UP):
		y -= 1.0
	if Input.is_physical_key_pressed(KEY_DOWN):
		y += 1.0
	var result := Vector2(x, y)
	return result.normalized() if result != Vector2.ZERO else Vector2.ZERO

func _fire_projectile(direction: Vector2) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as ProjectileBullet
	if projectile == null:
		return
	projectile.global_position = _muzzle.global_position
	projectile.direction = direction.normalized()
	projectile.damage = base_projectile_damage * GameState.get_damage_multiplier()
	get_tree().current_scene.add_child(projectile)

func apply_damage(amount: float) -> void:
	_stats.apply_damage(amount)

func refresh_from_equipment() -> void:
	_stats.recalculate_max_hp()
	_stats.heal_full()

func get_hp_values() -> Vector2:
	return Vector2(_stats.hp, _stats.max_hp)

func _on_hp_changed(current_hp: float, max_hp: float) -> void:
	emit_signal("hp_changed", current_hp, max_hp)

func _on_died() -> void:
	set_physics_process(false)
	visible = false
	emit_signal("died")
