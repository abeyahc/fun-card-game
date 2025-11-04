extends Node2D
class_name Card

signal played(target: Node)

@export var card_name: String = "Placeholder"
@export var cost: int = 0
@export var payload: Dictionary = {}

func play(target: Node = null) -> void:
	played.emit(target)

