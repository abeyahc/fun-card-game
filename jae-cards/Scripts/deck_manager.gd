extends Node
class_name DeckManager


@export var card_pool: Array[PackedScene] = []
@export var deck_p1_path: NodePath
@export var deck_p2_path: NodePath

var decks := {}   

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

