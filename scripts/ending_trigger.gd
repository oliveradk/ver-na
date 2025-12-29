extends Area3D

@export var ending_text: String = "Find Ver"

func _ready() -> void:
	add_to_group("interactable")

func get_interaction_text() -> String:
	return ending_text

func interact() -> void:
	GameManager.trigger_ending()
