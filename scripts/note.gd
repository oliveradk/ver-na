extends Area3D
class_name NotePickup

@export var note_id: String = ""
@export var interaction_text: String = "Read note"
@export var is_backstory: bool = false

signal note_read(note_data: Dictionary)

func _ready() -> void:
	add_to_group("interactable")

func get_interaction_text() -> String:
	return interaction_text

func interact() -> void:
	var note_data = GameManager.collect_note(note_id)
	if note_data:
		note_read.emit(note_data)
		# Find the UI controller and show the note
		var ui = get_tree().get_first_node_in_group("ui_controller")
		if ui:
			ui.show_note(note_data)
