extends Node

var is_server := false
var server_port := 9000
var server_ip := "127.0.0.1"
const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func host(port := 9000) -> bool:
	is_server = true
	server_port = port
	var p := ENetMultiplayerPeer.new()
	var err := p.create_server(server_port)
	if err != OK:
		push_error("Host failed: %s" % err)
		return false
	multiplayer.multiplayer_peer = p
	print("Server started on ", server_port)
	return true

func join(ip: String, port := 9000) -> bool:
	is_server = false
	server_ip = ip
	server_port = port
	var p := ENetMultiplayerPeer.new()
	var err := p.create_client(server_ip, server_port)
	if err != OK:
		push_error("Join failed: %s" % err)
		return false
	multiplayer.multiplayer_peer = p
	print("Client connecting to ", server_ip, ":", server_port)
	return true

func stop() -> void:
	if multiplayer.multiplayer_peer:
		var p := multiplayer.multiplayer_peer
		if p is ENetMultiplayerPeer:
			(p as ENetMultiplayerPeer).close()
		multiplayer.multiplayer_peer = null
	is_server = false

func _on_server_disconnected() -> void:
	print("Server disconnected, returning to main menu.")
	stop()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_connection_failed() -> void:
	print("Failed to connect to server, returning to main menu.")
	stop()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_peer_disconnected(id: int) -> void:
	print("Peer ", id, " disconnected.")
	if is_server:
		print("Client left, ending match and returning to main menu (server).")
		stop()
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
