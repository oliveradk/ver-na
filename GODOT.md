# Godot 4.x Common Gotchas

A reference for avoiding common pitfalls in Godot game development.

## 1. Collision & Physics

### MeshInstance3D Has No Collision

**Problem**: `MeshInstance3D` is purely visual. Players/objects pass right through.

**Solution**: Wrap in `StaticBody3D` (or `RigidBody3D`/`CharacterBody3D`) with a `CollisionShape3D`:

```
StaticBody3D
  ├── CollisionShape3D  (with BoxShape3D, CapsuleShape3D, etc.)
  └── MeshInstance3D    (visual mesh)
```

**In .tscn format**:
```
[node name="Wall" type="StaticBody3D" parent="."]
collision_layer = 1
collision_mask = 1

[node name="CollisionShape3D" type="CollisionShape3D" parent="Wall"]
shape = SubResource("BoxShape3D_wall")

[node name="MeshInstance3D" type="MeshInstance3D" parent="Wall"]
mesh = SubResource("BoxMesh_wall")
```

### Thin Collisions Get Tunneled Through

**Problem**: Fast-moving objects pass through thin collision shapes (< 0.5 units).

**Solution**:
- Make collision shapes at least 1 unit thick
- For floors: position so top surface is at y=0, collision extends downward
- Enable "Continuous CD" on fast-moving RigidBody3D nodes

### Collision Layers Not Set Up

**Problem**: Objects don't collide or detect each other.

**Solution**: Understand the layer/mask system:
- `collision_layer`: What layer(s) THIS object is ON
- `collision_mask`: What layer(s) THIS object DETECTS

Common setup:
- Layer 1: World geometry (floors, walls, buildings)
- Layer 2: Interactables (pickups, triggers, doors)
- Layer 3: Player
- Layer 4: Enemies

Player example: `collision_layer = 3, collision_mask = 1 | 2 | 4` (is on layer 3, detects 1, 2, and 4)

## 2. RayCast Detection

### RayCast3D Doesn't Detect Area3D

**Problem**: `RayCast3D` only detects physics bodies by default, not `Area3D` nodes.

**Solution**: Enable area detection on the RayCast3D:
```
[node name="InteractionRay" type="RayCast3D" parent="Camera3D"]
enabled = true
collide_with_areas = true
collide_with_bodies = true
collision_mask = 3  # Detect layers 1 and 2
```

### RayCast3D Not Working At All

**Problem**: RayCast3D returns nothing.

**Checklist**:
1. `enabled = true` (disabled by default!)
2. `target_position` is set (default is zero vector)
3. `collision_mask` includes the target's `collision_layer`
4. Target has a `CollisionShape3D` child

## 3. Input Handling

### Same Input Triggers Multiple Actions

**Problem**: Pressing a key opens AND immediately closes a menu/note.

**Solution**: Add a delay before allowing the reverse action:
```gdscript
var can_close: bool = false

func open_menu():
    menu_open = true
    can_close = false
    await get_tree().create_timer(0.2).timeout
    can_close = true

func _process(_delta):
    if menu_open and can_close and Input.is_action_just_pressed("interact"):
        close_menu()
```

### Input Not Received in CanvasLayer/UI

**Problem**: `_input()` doesn't fire for UI elements.

**Solutions**:
- Use `_unhandled_input()` for game input (fires after UI processing)
- Use `_input()` for UI that should block game input
- Check input directly in `_process()` with `Input.is_action_just_pressed()`

### Mouse Not Captured/Released Properly

**Problem**: Mouse stuck or not responding in first-person games.

**Solution**:
```gdscript
# Capture mouse (hide and lock)
Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Release mouse (show and unlock)
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Toggle on ESC
if event.is_action_pressed("ui_cancel"):
    if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    else:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
```

## 4. Scene Structure

### Node References Are Null

**Problem**: `@onready var node = $Path/To/Node` is null.

**Causes**:
1. Path is wrong (case-sensitive!)
2. Node doesn't exist yet when script runs
3. Node is in a different scene

**Solutions**:
- Double-check exact path and spelling
- Use `await get_tree().process_frame` before accessing
- Use `get_tree().get_first_node_in_group("group_name")` for cross-scene access

### Autoload/Singleton Not Found

**Problem**: Global script like `GameManager` not accessible.

**Solution**: Register in Project Settings → Autoload:
```
Name: GameManager
Path: res://scripts/game_manager.gd
```

Access anywhere: `GameManager.some_function()`

## 5. CharacterBody3D (Player Controllers)

### Player Falls Through Floor

**Problem**: `CharacterBody3D` falls through `StaticBody3D` floor.

**Checklist**:
1. Floor has `CollisionShape3D` (not just mesh)
2. Floor `collision_layer` matches player `collision_mask`
3. Floor collision is thick enough (1+ units)
4. Player collision shape isn't starting inside the floor
5. `move_and_slide()` is being called in `_physics_process()`

### Player Slides on Slopes

**Problem**: Player slides down slopes when standing still.

**Solution**:
```gdscript
# In CharacterBody3D
floor_stop_on_slope = true
floor_max_angle = deg_to_rad(45)  # Max walkable angle
```

### Jittery Movement

**Problem**: Player movement is choppy.

**Solutions**:
- Use `_physics_process()` not `_process()` for movement
- Interpolate camera separately if needed
- Check for conflicting velocity modifications

## 6. Signals & Groups

### Signal Not Connecting

**Problem**: `signal.connect(callable)` doesn't work.

**Solutions**:
```gdscript
# Method 1: In code
my_signal.connect(_on_my_signal)

# Method 2: In editor, use the Node dock → Signals tab

# Method 3: For child nodes in .tscn
[connection signal="pressed" from="Button" to="." method="_on_button_pressed"]
```

### Finding Nodes Across Scenes

**Problem**: Need to access a node that's in a different scene.

**Solution**: Use groups:
```gdscript
# Add to group (in _ready or editor)
add_to_group("player")
add_to_group("enemies")

# Find from anywhere
var player = get_tree().get_first_node_in_group("player")
var all_enemies = get_tree().get_nodes_in_group("enemies")
```

## 7. Scene Transitions

### Scene Change Crashes/Errors

**Problem**: `change_scene_to_file()` causes errors.

**Solutions**:
```gdscript
# Correct path format
get_tree().change_scene_to_file("res://scenes/level.tscn")

# If you need to do cleanup first
await get_tree().process_frame
get_tree().change_scene_to_file("res://scenes/level.tscn")
```

### Data Lost Between Scenes

**Problem**: Variables reset when changing scenes.

**Solution**: Use an Autoload singleton to persist data:
```gdscript
# In GameManager.gd (autoload)
var player_health: int = 100
var current_level: String = "home"
var collected_items: Array = []
```

## 8. Visual/Rendering

### Object Not Visible

**Checklist**:
1. `visible = true` on the node
2. Material is assigned to mesh
3. Object is within camera frustum
4. Object isn't too small or too far
5. No parent node has `visible = false`

### Transparency Not Working

**Problem**: Material with alpha < 1 isn't transparent.

**Solution**: In StandardMaterial3D:
```
transparency = ALPHA
# or for cutout (no blending)
transparency = ALPHA_SCISSOR
alpha_scissor_threshold = 0.5
```

## Quick Reference: Node Type Purposes

| Node Type | Purpose | Has Physics? |
|-----------|---------|--------------|
| `Node3D` | Empty transform, grouping | No |
| `MeshInstance3D` | Visual mesh only | No |
| `StaticBody3D` | Immovable solid (walls, floors) | Yes |
| `RigidBody3D` | Physics-driven object | Yes |
| `CharacterBody3D` | Player/NPC with custom movement | Yes |
| `Area3D` | Trigger zone, detection | Overlap only |
| `RayCast3D` | Line-of-sight detection | Query only |
