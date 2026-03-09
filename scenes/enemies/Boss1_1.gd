extends EnemyBase

func _ready() -> void:
	move_speed = 90.0
	max_hp = 300.0
	touch_damage = 20.0
	attack_cooldown = 0.6
	super._ready()
