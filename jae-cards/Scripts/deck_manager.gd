extends Node
class_name DeckManager

@export var card_pool: Array[PackedScene] = []
@export var deck_path: NodePath   

var deck: Deck = null

func _ready() -> void:
	if deck_path != NodePath(""):
		deck = get_node_or_null(deck_path) as Deck
	elif has_node("DeckP1"):
		deck = get_node("DeckP1") as Deck
	elif has_node("DeckP2"):
		deck = get_node("DeckP2") as Deck

	if deck == null:
		return

	deck.needs_cards.connect(_on_needs_cards.bind(deck))
	deck.refill()

func _on_needs_cards(owner_id: StringName, missing: int, deck_ref: Deck) -> void:
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
