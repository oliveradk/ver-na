extends CharacterBody3D

@export var move_speed: float = 4.0
@export var mouse_sensitivity: float = 0.002
@export var interaction_distance: float = 3.0
@export var gravity: float = 20.0

@onready var camera: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay
@onready var interaction_label: Label = $InteractionLabel

var can_move: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Ensure proper floor detection
	floor_stop_on_slope = true
	floor_max_angle = deg_to_rad(45)

func _input(event: InputEvent) -> void:
	if not can_move:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2.2, PI/2.2)

	if event.is_action_pressed("interact"):
		try_interact()

	if event.is_action_pressed("pause"):
		toggle_pause()

func _physics_process(delta: float) -> void:
	if not can_move:
		return

	# Get input direction
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Calculate movement direction relative to camera
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

	# Update interaction hint
	update_interaction_hint()

func update_interaction_hint() -> void:
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider.is_in_group("interactable"):
			interaction_label.text = "[E] " + collider.get_interaction_text()
			interaction_label.visible = true
			return
	interaction_label.visible = false

func try_interact() -> void:
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider.has_method("interact"):
			collider.interact()

func toggle_pause() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_can_move(value: bool) -> void:
	can_move = value
	if not value:
		velocity = Vector3.ZERO
