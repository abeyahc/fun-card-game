extends Node
class_name DeckManager

signal turn_changed(curr_p_id: StringName)

@export var card_pool: Array[PackedScene] = []
@export var deck_p1_path: NodePath
@export var deck_p2_path: NodePath

var decks := {}
var curr_p_id: StringName = "P1"
var turn_number := 1

func _ready() -> void:
	var d1: Deck = null
	if deck_p1_path != NodePath(""):
		d1 = get_node_or_null(deck_p1_path) as Deck
	elif has_node("DeckP1"):
		d1 = get_node("DeckP1") as Deck

	var d2: Deck = null
	if deck_p2_path != NodePath(""):
		d2 = get_node_or_null(deck_p2_path) as Deck
	elif has_node("DeckP2"):
		d2 = get_node("DeckP2") as Deck

	if d1:
		decks[String(d1.owner_id)] = d1
		d1.needs_cards.connect(_on_needs_cards.bind(d1))
		d1.refill()
	else:
		push_warning("DeckManager: DeckP1 not found (set deck_p1_path or add child 'DeckP1').")

	if d2:
		decks[String(d2.owner_id)] = d2
		d2.needs_cards.connect(_on_needs_cards.bind(d2))
		d2.refill()
	else:
		push_warning("DeckManager: DeckP2 not found (set deck_p2_path or add child 'DeckP2').")
	
	print("[DeckManager] Starting turn for Player ", curr_p_id)
	emit_signal("turn_changed", curr_p_id)
	
func get_curr_deck() -> Deck:
	return decks.get(curr_p_id, null)

func next_turn() -> void:
	if curr_p_id == "P1":
		curr_p_id = "P2"
	else:
		curr_p_id = "P1"
	turn_number += 1
	print("[DeckManager] Turn", turn_number, "- it's now", curr_p_id, "'s turn")
	emit_signal("turn_changed", curr_p_id)

func play_turn() -> void:
	var deck := get_curr_deck()
	if not deck:
		push_warning("No deck found for" + str(curr_p_id))
		return
	
	print("[DeckManager] Player ", curr_p_id, "is playing their turn")
	deck.give_card(_make_card_node())
	
	# end and pass to the next player
	next_turn()

func _on_needs_cards(owner_id: StringName, missing: int, deck_ref: Deck) -> void:
	print("[DeckManager] grant ", missing, " card(s) to ", String(owner_id))
	deck_ref.begin_bulk_fill()
	for i in range(missing):
		var card := _make_card_node()
		deck_ref.give_card(card)
	deck_ref.end_bulk_fill()

func _make_card_node() -> Card:
	if not card_pool.is_empty():
		var ps := card_pool[randi() % card_pool.size()]
		return ps.instantiate() as Card
	return Card.new()

