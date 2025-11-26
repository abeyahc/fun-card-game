extends Node

@onready var p1 := $P1
@onready var p2 := $P2
@onready var turn_label: Label = $UI/TurnLabel

var active_owner: StringName = &""
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	print("[World] _ready on peer", multiplayer.get_unique_id(), " Net.is_server=", Net.is_server)


	#CAN ERASE, TEST LABEL
	if turn_label:
		print("[World] TurnLabel found at path:", turn_label.get_path())
		turn_label.visible = true
		turn_label.modulate = Color(1, 1, 1, 1)
		turn_label.add_theme_color_override("font_color", Color(1, 0, 0))
		turn_label.add_theme_font_size_override("font_size", 32)
		turn_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
		turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		turn_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		turn_label.position = Vector2(0, 10)
	else:
		push_error("[World] TurnLabel is NULL! Check $UI/TurnLabel path.")

	#END OF TEST LABEL

	if Net.is_server:
		p1.set_multiplayer_authority(1)
		multiplayer.peer_connected.connect(_on_peer_connected)
		rng.randomize()
		print("[World] Server initialized, waiting for client to connect.")
	else:
		print("[World] I am a client, waiting for turn sync from server.")

	_update_label()

@rpc("any_peer", "call_local")
func set_p1_authority(peer_id: int) -> void:
	print("[World] set_p1_authority called on peer", multiplayer.get_unique_id(), "->", peer_id)
	p1.set_multiplayer_authority(peer_id)

@rpc("any_peer", "call_local")
func set_p2_authority(peer_id: int) -> void:
	print("[World] set_p2_authority called on peer", multiplayer.get_unique_id(), "->", peer_id)
	p2.set_multiplayer_authority(peer_id)

func _on_peer_connected(peer_id: int) -> void:
	print("[World] _on_peer_connected, new peer:", peer_id)

	p2.set_multiplayer_authority(peer_id)
	rpc("set_p2_authority", peer_id)
	rpc_id(peer_id, "set_p1_authority", 1)

	if Net.is_server:
		print("[World] Both players ready, starting turns.")
		_start_turns()

func _start_turns() -> void:
	var first: StringName = &"P1" if rng.randi() % 2 == 0 else &"P2"
	print("[World] _start_turns picked first:", String(first))
	_set_turn(first)

func _set_turn(owner_id: StringName) -> void:
	print("[World] _set_turn on SERVER to", String(owner_id))
	active_owner = owner_id
	_update_label()
	rpc("_sync_turn", owner_id)

@rpc("any_peer", "call_local")
func _sync_turn(owner_id: StringName) -> void:
	print("[World] _sync_turn on peer", multiplayer.get_unique_id(), "->", String(owner_id))
	active_owner = owner_id
	_update_label()

func _update_label() -> void:
	var txt := ""
	if active_owner == &"":
		txt = "Waiting for players..."
	else:
		txt = "Turn: " + String(active_owner)

	if turn_label:
		turn_label.text = txt
		print("[World] _update_label ->", txt, " (peer", multiplayer.get_unique_id(), ")")
	else:
		print("[World] _update_label called but turn_label is NULL (peer", multiplayer.get_unique_id(), ")")

func is_players_turn(owner_id: StringName) -> bool:
	var same := active_owner == owner_id
	print("[World] is_players_turn? owner_id=", String(owner_id), " active_owner=", String(active_owner), " -> ", same, " (peer ", multiplayer.get_unique_id(), ")")
	return same

func request_end_turn(owner_id: StringName) -> void:
	print("[World] request_end_turn() CALLED LOCALLY on peer", multiplayer.get_unique_id(), "owner_id=", String(owner_id)," Net.is_server=", Net.is_server)
	if Net.is_server:
		_rpc_request_end_turn(owner_id)
	else:
		rpc("_rpc_request_end_turn", owner_id)

@rpc("any_peer")
func _rpc_request_end_turn(owner_id: StringName) -> void:
	print("[World] _rpc_request_end_turn FROM peer", multiplayer.get_remote_sender_id(), " running on peer", multiplayer.get_unique_id(), " owner_id=", String(owner_id), " active_owner=", String(active_owner), " Net.is_server=", Net.is_server)

	if not Net.is_server:
		print("[World] _rpc_request_end_turn ignored here: not server.")
		return

	if owner_id != active_owner:
		print("[World] _rpc_request_end_turn ignored: not that player's turn.")
		return

	var next := &"P2" if active_owner == &"P1" else &"P1"
	print("[World] Turn ends for", String(active_owner), " -> switching to ", String(next))
	_set_turn(next)


