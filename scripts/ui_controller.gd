extends CanvasLayer

@onready var note_panel: Panel = $NotePanel
@onready var note_title: Label = $NotePanel/VBoxContainer/NoteTitle
@onready var note_content: Label = $NotePanel/VBoxContainer/NoteContent
@onready var close_hint: Label = $NotePanel/VBoxContainer/CloseHint
@onready var fade_overlay: ColorRect = $FadeOverlay

var player: CharacterBody3D = null
var is_note_open: bool = false
var can_close: bool = false

func _ready() -> void:
	add_to_group("ui_controller")
	note_panel.visible = false
	fade_overlay.visible = false

	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if is_note_open and can_close and event.is_action_pressed("interact"):
		close_note()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	# Alternative: check input directly each frame when note is open
	if is_note_open and can_close and Input.is_action_just_pressed("interact"):
		close_note()

func show_note(note_data: Dictionary) -> void:
	is_note_open = true
	can_close = false
	note_title.text = note_data.get("title", "Note")
	note_content.text = note_data.get("content", "")
	note_panel.visible = true

	if player:
		player.set_can_move(false)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Wait a moment before allowing close to prevent same-frame close
	await get_tree().create_timer(0.2).timeout
	can_close = true

func close_note() -> void:
	is_note_open = false
	can_close = false
	note_panel.visible = false

	if player:
		player.set_can_move(true)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func fade_to_black(duration: float = 1.0) -> void:
	fade_overlay.visible = true
	fade_overlay.color = Color(0, 0, 0, 0)

	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), duration)
	await tween.finished

func fade_from_black(duration: float = 1.0) -> void:
	fade_overlay.visible = true
	fade_overlay.color = Color(0, 0, 0, 1)

	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), duration)
	await tween.finished

	fade_overlay.visible = false
