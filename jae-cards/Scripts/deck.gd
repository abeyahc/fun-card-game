extends Node
class_name Deck

signal needs_cards(owner_id: StringName, missing: int)
signal hand_count_changed(count: int)

@export var owner_id: StringName = &"P1"
@export var max_hand_size: int = 6
var _is_filling := false

func _ready() -> void:
	_ensure_min_hand()

func refill() -> void:
	_ensure_min_hand()

func begin_bulk_fill() -> void: _is_filling = true
func end_bulk_fill() -> void: _is_filling = false; _emit_count_and_top_off()

func give_card(card_src) -> void:
	var card: Card = null
	
	if card_src is PackedScene:
		card = (card_src as PackedScene).instantiate() as Card
	elif card_src is Card:
		card = card_src
	if card == null: 
		return

	card.name = "Card_%d" % get_child_count()
	add_child(card)
	
	if not _is_filling:
		_emit_count_and_top_off()
func _emit_count_and_top_off() -> void:
	var c := get_child_count()
	print("[Deck] hand count =", c)
	hand_count_changed.emit(c)
	if not _is_filling: _ensure_min_hand()

func _ensure_min_hand() -> void:
	if _is_filling: 
		return

	var missing := max_hand_size - get_child_count()

	if missing > 0:
		needs_cards.emit(owner_id, missing)
