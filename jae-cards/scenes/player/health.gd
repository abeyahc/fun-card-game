extends TextureProgressBar

@onready var timer: Timer = $DamageTimer
@onready var damage_bar: TextureProgressBar = $DamageBar

var health: float = 0.0

func init_health(start_health: float) -> void:
	health = start_health
	max_value = start_health
	value = start_health
	damage_bar.max_value = start_health
	damage_bar.value = start_health

func set_health(new_health: float) -> void:
	var prev := health
	health = min(max_value, new_health)
	value = health
	if health <= 0.0:
		queue_free()
	if health < prev:
		timer.start()
	else:
		damage_bar.value = health

func _on_DamageTimer_timeout() -> void:
	damage_bar.value = health
