extends Node
class_name Deck

signal needs_cards(owner_id: StringName, missing: int)
signal hand_count_changed(count: int)

@export var owner_id: StringName = &"P1"
@export var max_hand_size: int = 6

var _is_filling := false

func _ready() -> void:
	if multiplayer.is_server():
		randomize()


func refill() -> void:
	if multiplayer.is_server():
		_ensure_min_hand()


func begin_bulk_fill() -> void:
	_is_filling = true


func end_bulk_fill() -> void:
	_is_filling = false
	_emit_count()


func give_card(card_src: Variant) -> void:
	if not multiplayer.is_server():
		return

	var card: Card = null
	if card_src is PackedScene:
		card = (card_src as PackedScene).instantiate() as Card
	elif card_src is Card:
		card = card_src
	if card == null:
		return

	card.name = "Card_%d" % _card_count()
	add_child(card)

	print("[Deck ", owner_id, "] added ", card.name)

	_emit_count()

func _emit_count() -> void: 
	var c := _card_count() 
	print("[Deck ", owner_id, "] card count = ", c) 
	hand_count_changed.emit(c) 

func _ensure_min_hand() -> void: 
	var missing := max_hand_size - _card_count() 
	if missing > 0: 
		print("[Deck ", owner_id, "] needs ", missing) 
		needs_cards.emit(owner_id, missing) 

func _card_count() -> int: 
	var n := 0 
	for child in get_children(): 
		if child is Card: 
			n += 1 
	return n
