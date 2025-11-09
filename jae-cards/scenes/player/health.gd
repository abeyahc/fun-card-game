extends TextureProgressBar

@onready var timer:Timer = $DamageTimer
@onready var damage_bar:TextureProgressBar = $DamageBar

# set_health called every everytime health value changes
var health:float = 0 : set = _set_health

func init_health(start_health:float) -> void:
	health = start_health
	max_value = health
	value = health
	
	damage_bar.max_value = health
	damage_bar.value = health
	
func _set_health(new_health: float) -> void:
	var prev_health:float = health
	# when healed, can go over
	health = min(max_value, new_health)
	value = health
	
	# on player death
	if health <= 0:
		queue_free()
	# damage taken, else healed
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

# damage bar receeds back to health bar
func _on_damage_timer_timeout():
	damage_bar.value = health
