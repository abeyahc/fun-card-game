extends Control

@onready var ip_field: LineEdit  = $VBoxContainer/IP
@onready var port_field: SpinBox = $VBoxContainer/Port
@export var world_scene := "res://scenes/world.tscn"

func _on_host_pressed() -> void:
	var port := int(port_field.value)
	if Net.host(port):
		get_tree().change_scene_to_file(world_scene)

func _on_join_pressed() -> void:
	var ip := ip_field.text.strip_edges()
	if ip == "":
		ip = "127.0.0.1"
	var port := int(port_field.value)
	if Net.join(ip, port):
		get_tree().change_scene_to_file(world_scene)

func _on_options_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	Net.stop()
	get_tree().quit()
