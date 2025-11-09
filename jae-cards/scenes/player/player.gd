extends Node2D

@onready var healthbar: TextureProgressBar = $HPBar

var health:float = 100
var alive:bool = true

func _ready():
	healthbar.init_health(health)

func _set_health(value):
	health = value
	healthbar.health = health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_bar_tester_pressed():
	health -= 10
	_set_health(health)
