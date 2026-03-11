extends Node2D

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const MELEE_SCENE := preload("res://scenes/enemies/MeleeEnemy.tscn")
const BOSS_SCENE := preload("res://scenes/enemies/Boss1_1.tscn")
const PICKUP_SCENE := preload("res://scenes/equipment/EquipmentPickup.tscn")
const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const HUB_SCENE_PATH := "res://scenes/levels/Hub.tscn"
const STAGE_ID := "1-2"
const WAVE_ENEMY_COUNT := 8

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

func _ready() -> void:
	_spawn_player()
	if _player == null:
		return
	_spawn_wave(WAVE_ENEMY_COUNT)
	_hud = HUD_SCENE.instantiate() as StageHUD
	if _hud == null:
		return
	add_child(_hud)
	var hp_values := _player.get_hp_values()
	_hud.set_hp(hp_values.x, hp_values.y)
	_set_hud_status("Stage 1-2: Clear mobs to summon the boss")

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
	for _i: int in range(count):
		var enemy := MELEE_SCENE.instantiate() as EnemyBase
		if enemy == null:
			continue
		var offset := Vector2(randf_range(-360.0, 360.0), randf_range(-240.0, 240.0))
		enemy.global_position = player_spawn.global_position + offset
		enemy.set_target(_player)
		enemy.died.connect(_on_enemy_died)
		enemy_container.add_child(enemy)
		_active_enemy_count += 1

func _spawn_boss() -> void:
	var boss := BOSS_SCENE.instantiate() as EnemyBase
	if boss == null:
		return
	_boss_spawned = true
	boss.global_position = boss_spawn.global_position
	boss.set_target(_player)
	boss.died.connect(_on_boss_died)
	enemy_container.add_child(boss)
	_set_hud_status("Stage 1-2 boss engaged")

func _on_enemy_died(_enemy: EnemyBase) -> void:
	if _stage_complete:
		return
	_active_enemy_count = max(_active_enemy_count - 1, 0)
	if _active_enemy_count == 0 and not _boss_spawned:
		_spawn_boss()

func _on_boss_died(boss: EnemyBase) -> void:
	if _stage_complete:
		return
	var drop_id := GameState.roll_boss_drop(STAGE_ID)
	var reward_spawn_position := boss_spawn.global_position
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
	_set_hud_status("Stage 1-2 boss defeated. Pick up the equipment")

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
		var equipped_name := GameState.get_equipment_name(equipment_id)
		_set_hud_status("Equipped: %s. Stage 1-2 clear! Returning to Hub..." % equipped_name)
	else:
		_set_hud_status("Stage 1-2 clear! Returning to Hub...")
	if _player != null and _player.has_method("refresh_from_equipment"):
		_player.refresh_from_equipment()
	_return_to_hub(2.0)

func _on_player_hp_changed(current_hp: float, max_hp: float) -> void:
	if _hud != null:
		_hud.set_hp(current_hp, max_hp)

func _on_player_died() -> void:
	if _stage_complete or _is_returning_to_hub:
		return
	_set_hud_status("You died in Stage 1-2. Returning to Hub...")
	_return_to_hub(2.0)

func _set_hud_status(text: String) -> void:
	if _hud != null:
		_hud.set_status(text)

func _return_to_hub(delay: float) -> void:
	_is_returning_to_hub = true
	var timer := get_tree().create_timer(delay)
	timer.timeout.connect(func() -> void:
		get_tree().change_scene_to_file(HUB_SCENE_PATH)
	)
