extends Node2D
class_name Player_User

@onready var healthbar: TextureProgressBar = $HPBar
@export var owner_id: StringName = &"P1"        
@export var deck_path: NodePath                  
var deck: Deck

var health:float = 100
var alive:bool = true

func _ready() -> void:
	healthbar.init_health(health)
	deck = get_node_or_null(deck_path) as Deck
	if deck == null:
		push_warning("Player (" + String(owner_id) + "): deck_path not set to a Deck.")

func _set_health(value):
	health = value
	healthbar.health = health

func _process(delta):
	pass

func _on_bar_tester_pressed():
	health -= 10
	_set_health(health)


