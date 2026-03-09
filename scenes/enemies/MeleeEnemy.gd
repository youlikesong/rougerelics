extends EnemyBase

func _ready() -> void:
	move_speed = 110.0
	max_hp = 50.0
	touch_damage = 12.0
	attack_cooldown = 0.9
	super._ready()
