extends Node

# Game state
var notes_collected: Array[String] = []
var backstory_notes_collected: Array[String] = []
var current_level: String = "home"

# Note content
var main_notes: Dictionary = {
	"fridge_note": {
		"title": "Note on the Fridge",
		"content": "Taking Fran to the park!\nBack soon.\n\nLove you - V",
		"location": "home"
	},
	"dog_park_note": {
		"title": "Note on the Bench",
		"content": "To whoever was here with the brown dog -\n\nI found this phone on the ground after you left in such a hurry. I left it at the front desk of the vet clinic on Main St.\n\nHope your pup is okay, you seemed really worried.\n\n- A fellow dog parent",
		"location": "dog_park"
	},
	"vet_desk_note": {
		"title": "Receptionist's Note",
		"content": "Patient: Fran\nOwner: Ver\nStatus: In recovery\n\nOwner is in waiting room 3.\n(Arrow pointing to hallway)",
		"location": "vet_clinic"
	}
}

var backstory_notes: Dictionary = {
	"college_memory": {
		"title": "A Memory",
		"content": "The first night we talked until 4am.\nI knew.\n\nI didn't know what I knew, exactly.\nBut I knew.",
		"location": "town"
	},
	"maine_drive": {
		"title": "Ticket Stub",
		"content": "12 hours in that tiny car.\nWe sang every song wrong.\n\nYou fell asleep somewhere in Connecticut.\nI drove in silence, just happy.",
		"location": "town"
	},
	"wedding_day": {
		"title": "Dried Flower Petal",
		"content": "You in that dress.\nFran tried to eat the flowers.\n\nEveryone laughed.\nI cried.",
		"location": "town"
	},
	"movie_night": {
		"title": "Old Ticket Stub",
		"content": "Our 47th movie night.\nStill holding hands.\n\n(I stopped counting after this one.\nThere were too many to count.)",
		"location": "town"
	},
	"coffee_shop": {
		"title": "Napkin",
		"content": "(A napkin with doodles)\n\nFran with hearts around her.\n'V + N' in a heart.\nA tiny house with smoke from the chimney.",
		"location": "town"
	},
	"grad_school": {
		"title": "A Thought",
		"content": "You moved here for me.\n\nI think about that every day.\nI'll never stop being grateful.\n\nI'll never stop trying to deserve it.",
		"location": "town"
	}
}

signal note_collected(note_id: String)
signal level_changed(new_level: String)
signal game_ended

func _ready() -> void:
	pass

func collect_note(note_id: String) -> Dictionary:
	if note_id in main_notes:
		if note_id not in notes_collected:
			notes_collected.append(note_id)
			note_collected.emit(note_id)
		return main_notes[note_id]
	elif note_id in backstory_notes:
		if note_id not in backstory_notes_collected:
			backstory_notes_collected.append(note_id)
			note_collected.emit(note_id)
		return backstory_notes[note_id]
	return {}

func change_level(level_name: String) -> void:
	current_level = level_name
	level_changed.emit(level_name)

	var scene_path = "res://scenes/levels/" + level_name + ".tscn"
	get_tree().change_scene_to_file(scene_path)

func trigger_ending() -> void:
	game_ended.emit()
	get_tree().change_scene_to_file("res://scenes/ui/ending.tscn")

func get_notes_count() -> int:
	return notes_collected.size() + backstory_notes_collected.size()

func get_total_notes() -> int:
	return main_notes.size() + backstory_notes.size()
