extends Node2D

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const MELEE_SCENE := preload("res://scenes/enemies/MeleeEnemy.tscn")
const G2_SCENE := preload("res://scenes/enemies/G2Enemy.tscn")
const G3_SCENE := preload("res://scenes/enemies/G3Enemy.tscn")
const BOSS_SCENE := preload("res://scenes/enemies/Boss1_1.tscn")
const PICKUP_SCENE := preload("res://scenes/equipment/EquipmentPickup.tscn")
const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const HUB_SCENE_PATH := "res://scenes/levels/Hub.tscn"
const STAGE_ID := "1-3"
const WAVE_COUNTS := [7, 8, 9]
const WAVE_G2_COUNTS := [0, 2, 3]
const WAVE_G3_COUNTS := [0, 0, 2]
const WAVE_TRANSITION_DELAY := 1.2

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var boss_spawn: Marker2D = $BossSpawn
@onready var enemy_container: Node2D = $EnemyContainer
@onready var pickup_container: Node2D = $PickupContainer

var _player: PlayerCharacter
var _hud: StageHUD
var _active_enemy_count: int = 0
var _boss_spawned: bool = false
var _stage_complete: bool = false
var _is_returning_to_hub: bool = false
var _current_wave_index: int = -1
var _wave_transition_pending: bool = false

func _ready() -> void:
	_spawn_player()
	if _player == null:
		return

	_hud = HUD_SCENE.instantiate() as StageHUD
	if _hud == null:
		return

	add_child(_hud)

	var hp_values: Vector2 = _player.get_hp_values()
	_hud.set_hp(hp_values.x, hp_values.y)
	_set_hud_status("Stage 1-3 start: Clear wave 1")
	_start_next_wave()

func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate() as PlayerCharacter
	if _player == null:
		return

	_player.global_position = player_spawn.global_position
	_player.add_to_group("player")
	_player.hp_changed.connect(_on_player_hp_changed)
	_player.died.connect(_on_player_died)
	add_child(_player)

func _spawn_wave(count: int) -> void:
	if _player == null:
		return

	for i: int in range(count):
		var enemy_scene: PackedScene = _get_enemy_scene_for_wave(_current_wave_index, i, count)
		var enemy := enemy_scene.instantiate() as EnemyBase
		if enemy == null:
			continue

		var spawn_position: Vector2 = _get_wave_spawn_position(_current_wave_index, i)
		enemy.global_position = spawn_position
		enemy.set_target(_player)
		enemy.died.connect(_on_enemy_died)
		enemy_container.add_child(enemy)
		_active_enemy_count += 1

func _get_enemy_scene_for_wave(wave_index: int, enemy_index: int, total_count: int) -> PackedScene:
	var g3_count: int = WAVE_G3_COUNTS[wave_index]
	var g3_start_index: int = max(total_count - g3_count, 0)
	if enemy_index >= g3_start_index:
		return G3_SCENE

	var g2_count: int = WAVE_G2_COUNTS[wave_index]
	var g2_start_index: int = max(total_count - g2_count - g3_count, 0)
	if enemy_index >= g2_start_index:
		return G2_SCENE

	return MELEE_SCENE

func _get_wave_spawn_position(wave_index: int, enemy_index: int) -> Vector2:
	match wave_index:
		0:
			return player_spawn.global_position + Vector2(
				randf_range(-320.0, 320.0),
				randf_range(-210.0, -60.0)
			)
		1:
			var side_sign: float = -1.0 if enemy_index % 2 == 0 else 1.0
			return player_spawn.global_position + Vector2(
				side_sign * randf_range(180.0, 360.0),
				randf_range(-220.0, 180.0)
			)
		2:
			var top_spawn: bool = enemy_index < 3
			if top_spawn:
				return player_spawn.global_position + Vector2(
					randf_range(-260.0, 260.0),
					randf_range(-260.0, -140.0)
				)
			return player_spawn.global_position + Vector2(
				randf_range(-420.0, 420.0),
				randf_range(40.0, 250.0)
			)
		_:
			return player_spawn.global_position + Vector2(
				randf_range(-360.0, 360.0),
				randf_range(-240.0, 240.0)
			)

func _start_next_wave() -> void:
	if _current_wave_index + 1 >= WAVE_COUNTS.size():
		_spawn_boss()
		return

	_current_wave_index += 1
	_wave_transition_pending = false
	_spawn_wave(WAVE_COUNTS[_current_wave_index])
	_set_hud_status("Stage 1-3: Wave %d in progress" % (_current_wave_index + 1))

func _spawn_boss() -> void:
	var boss := BOSS_SCENE.instantiate() as EnemyBase
	if boss == null:
		return

	_boss_spawned = true
	boss.global_position = boss_spawn.global_position
	boss.set_target(_player)
	boss.died.connect(_on_boss_died)
	enemy_container.add_child(boss)
	_set_hud_status("Stage 1-3 boss engaged")

func _on_enemy_died(_enemy: EnemyBase) -> void:
	if _stage_complete:
		return

	_active_enemy_count = max(_active_enemy_count - 1, 0)

	if _active_enemy_count == 0 and not _boss_spawned:
		if _current_wave_index + 1 < WAVE_COUNTS.size():
			if _wave_transition_pending:
				return

			_wave_transition_pending = true
			_set_hud_status("Stage 1-3: Next wave incoming")

			var timer: SceneTreeTimer = get_tree().create_timer(WAVE_TRANSITION_DELAY)
			timer.timeout.connect(func() -> void:
				if _stage_complete or _boss_spawned:
					return
				_start_next_wave()
			)
			return

		_spawn_boss()

func _on_boss_died(boss: EnemyBase) -> void:
	if _stage_complete:
		return

	var drop_id: String = GameState.roll_boss_drop(STAGE_ID)
	var reward_spawn_position: Vector2 = boss_spawn.global_position

	if is_instance_valid(boss):
		reward_spawn_position = boss.global_position

	if drop_id.is_empty():
		_on_equipment_equipped("")
		return

	var pickup := PICKUP_SCENE.instantiate() as EquipmentPickup
	if pickup == null:
		_on_equipment_equipped(drop_id)
		return

	pickup.global_position = reward_spawn_position
	pickup.equipment_id = drop_id
	pickup.equipped.connect(_on_equipment_equipped)
	pickup_container.add_child(pickup)
	_set_hud_status("Stage 1-3 boss defeated. Pick up the equipment")

func _on_equipment_equipped(equipment_id: String) -> void:
	if _stage_complete or _is_returning_to_hub:
		return

	if GameState.is_stage_cleared(STAGE_ID):
		_stage_complete = true
		_return_to_hub(0.1)
		return

	_stage_complete = true
	GameState.mark_stage_cleared(STAGE_ID)

	if not equipment_id.is_empty():
		var equipped_name: String = GameState.get_equipment_name(equipment_id)
		_set_hud_status("Equipped: %s. Stage 1-3 clear! Returning to Hub..." % equipped_name)
	else:
		_set_hud_status("Stage 1-3 clear! Returning to Hub...")

	if _player != null and _player.has_method("refresh_from_equipment"):
		_player.refresh_from_equipment()

	_return_to_hub(2.0)

func _on_player_hp_changed(current_hp: float, max_hp: float) -> void:
	if _hud != null:
		_hud.set_hp(current_hp, max_hp)

func _on_player_died() -> void:
	if _stage_complete or _is_returning_to_hub:
		return

	_set_hud_status("You died in Stage 1-3. Returning to Hub...")
	_return_to_hub(2.0)

func _set_hud_status(text: String) -> void:
	if _hud != null:
		_hud.set_status(text)

func _return_to_hub(delay: float) -> void:
	_is_returning_to_hub = true
	var timer: SceneTreeTimer = get_tree().create_timer(delay)
	timer.timeout.connect(func() -> void:
		get_tree().change_scene_to_file(HUB_SCENE_PATH)
	)
