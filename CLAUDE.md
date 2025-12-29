# Ver & Na - Walking Simulator

A Godot 4.x walking simulator about love, worry, and finding each other.

## Project Overview

Na searches for Ver after they don't return from the dog park with their white dog, Fran. The player discovers the story through notes scattered across 4 levels, leading to a happy resolution at the vet clinic.

## Story Flow

1. **Home** → Read fridge note → Exit through door
2. **Dog Park** → Read bench note (stranger found Ver's phone) → Exit through gate
3. **Town** → Optional backstory notes → Find the green vet clinic building at the end of the street
4. **Vet Clinic** → Read receptionist note → Enter waiting room 3 → Ending sequence

## Project Structure

```
scenes/
  levels/      - 4 main game levels (home, dog_park, town, vet_clinic)
  player/      - First-person player controller
  ui/          - Note popup, main menu, ending sequence
scripts/
  player.gd    - First-person movement + interaction
  note.gd      - Interactable note pickups
  game_manager.gd - Global autoload with all note content
  ui_controller.gd - Note display UI
  level_transition.gd - Scene transitions
  ending_trigger.gd - Triggers ending sequence
```

## Collision Layers

- **Layer 1**: Physical world (floors, walls, buildings) - player collides with these
- **Layer 2**: Interactables (notes, doors, triggers) - player raycast detects these

## GOTCHAS - Common Issues

### 1. Objects Have No Collision (Player Walks Through)

**Problem**: MeshInstance3D nodes are VISUAL ONLY - they have no physics collision.

**Solution**: For any object the player should collide with:
```
StaticBody3D (collision_layer=1, collision_mask=1)
  └── CollisionShape3D (with matching BoxShape3D/etc)
  └── MeshInstance3D (visual mesh)
```

**Affected objects**: Walls, floors, buildings, furniture - anything solid.

### 2. Interactables Not Detected by Player

**Problem**: Area3D nodes need proper collision layers for the player's RayCast3D to detect them.

**Solution**: All interactable Area3D nodes need:
```
collision_layer = 2
collision_mask = 2
```

And the player's InteractionRay needs:
```
collide_with_areas = true
collision_mask = 3  (detects both layer 1 and 2)
```

### 3. Note Opens But Won't Close

**Problem**: Same input event that opens the note immediately closes it.

**Solution**: Add a `can_close` flag with a short delay (0.2s) before allowing close. Check input in `_process()` using `Input.is_action_just_pressed()`.

### 4. Floor/Ground Collision Not Working

**Problem**: Thin collision shapes (0.2 units) can be tunneled through at high speeds.

**Solution**: Make floor collision shapes at least 1 unit thick. Position the StaticBody3D so the top surface is at y=0.

## Adding New Levels

1. Create scene inheriting the pattern from existing levels
2. Add Player instance + UI instance
3. Floor: StaticBody3D with thick collision (1+ units)
4. Walls/Buildings: StaticBody3D with CollisionShape3D + MeshInstance3D
5. Notes: Area3D with collision_layer=2, script=note.gd, set note_id
6. Exits: Area3D with collision_layer=2, script=level_transition.gd

## Controls

- WASD: Move
- Mouse: Look
- E: Interact / Close note
- ESC: Toggle mouse capture
