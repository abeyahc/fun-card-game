extends Node2D

@onready var healthbar: TextureProgressBar = $HPBar
@export var owner_id: StringName = &"P1"        
@export var deck_path: NodePath
@export var deck_manager_path: NodePath
			 
var deck: Deck
var deck_manager: DeckManager

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
	
	deck_manager = get_node(deck_manager_path) as DeckManager
	if deck_manager:
		deck_manager.play_turn()
	else:
		push_warning("DeckManager not found for player " + str(owner_id))


