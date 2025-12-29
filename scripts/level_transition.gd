extends Area3D

@export var target_level: String = ""
@export var transition_text: String = "Go outside"

func _ready() -> void:
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)

func get_interaction_text() -> String:
	return transition_text

func interact() -> void:
	trigger_transition()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		trigger_transition()

func trigger_transition() -> void:
	if target_level.is_empty():
		return

	var ui = get_tree().get_first_node_in_group("ui_controller")
	if ui:
		await ui.fade_to_black(0.5)

	GameManager.change_level(target_level)
