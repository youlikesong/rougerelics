# AGENTS.md

## Project
Godot 4.4 2D top-down action roguelite.
Inspired by The Binding of Isaac + Brotato + Warcraft RPG map progression.
Stage progression: start with 1-1 to 1-6.
Boss drops equipment. Equipment is permanent and wearable.

## Tech rules
- Engine: Godot 4.x
- Language: GDScript only
- Use typed GDScript where reasonable
- Keep scripts small and modular
- Avoid putting all logic into Player.gd
- Prefer reusable base classes for enemies and bosses
- Data-driven design for equipment, stages, drops

## Folder rules
- scenes/player
- scenes/enemies
- scenes/weapons
- scenes/equipment
- scenes/levels
- scenes/ui
- systems
- data

## Coding rules
- Do not rename files unless necessary
- Do not break existing scene paths
- Create missing files when needed
- Add comments only where logic is not obvious
- Keep code production-oriented, not demo hacks

## Current milestone
Build a playable vertical slice:
1. Player movement
2. 8-direction shooting
3. One normal enemy
4. Boss 1-1
5. Stage clear flow
6. Equipment drop and equip
7. Hub and stage unlock