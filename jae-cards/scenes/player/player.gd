extends Node2D

@onready var healthbar: TextureProgressBar = $HPBar
@export var owner_id: StringName = &"P1"
@export var deck_path: NodePath
var deck: Deck

var health: float = 100.0
var alive: bool = true

func _ready() -> void:
	healthbar.init_health(health)
	deck = get_node_or_null(deck_path) as Deck
	if deck == null:
		push_warning("Player (%s): deck_path not set." % String(owner_id))

func _set_health(value: float) -> void:
	health = value
	healthbar.set_health(health)

func _on_bar_tester_pressed() -> void:
	print("[Player ", String(owner_id), "] button click on peer ", multiplayer.get_unique_id(), " authority? ", is_multiplayer_authority())
	if not is_multiplayer_authority():
		return
	var world := get_tree().current_scene
	if world and world.has_method("is_players_turn") and not world.is_players_turn(owner_id):
		print("[Player ", String(owner_id), "] can't act: NOT YOUR TURN (client-side check).")
		return

	rpc("req_damage", 10)


@rpc("authority")
func req_damage(amount: int) -> void:
	var world := get_tree().current_scene
	if world and world.has_method("is_players_turn"):
		var ok: bool = world.is_players_turn(owner_id)
		print("[Player ", String(owner_id), "] req_damage on peer", multiplayer.get_unique_id(), " active_owner=", String(world.active_owner) if "active_owner" in world else "<?>", " is_players_turn? ", ok)
		if not ok:
			print("[Player ", String(owner_id), "] req_damage DENIED: not your turn.")
			return

	print("[Player ", String(owner_id), "] applying damage:", amount, " (peer ", multiplayer.get_unique_id(), ")")
	health -= float(amount)
	rpc("sync_health", health)
	if world and world.has_method("request_end_turn"):
		print("[Player ", String(owner_id), "] requesting end of turn")
		world.request_end_turn(owner_id)

@rpc("any_peer", "call_local")
func sync_health(v: float) -> void:
	_set_health(v)
