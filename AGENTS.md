# AGENTS.md

## Project
Godot 4.4 2D top-down action roguelite.

Inspired by:
- The Binding of Isaac
- Brotato
- Warcraft RPG-style stage progression

Core progression:
- Stage progression starts from 1-1 to 1-6
- Bosses can drop equipment
- Equipment is permanent and wearable
- Hub and stage unlock flow are part of the core loop

## Tech rules
- Engine: Godot 4.x
- Language: GDScript only
- Use typed GDScript where reasonable
- Keep scripts small and modular
- Avoid putting all logic into Player.gd
- Prefer reusable base classes for enemies and bosses
- Prefer data-driven design for equipment, stages, drops, and unlocks

## Folder rules
Use these folders unless there is a strong reason not to:
- scenes/player
- scenes/enemies
- scenes/weapons
- scenes/equipment
- scenes/levels
- scenes/ui
- systems
- data

## Coding rules
- Preserve existing architecture, scene structure, naming, and coding style
- Prefer minimal diffs over refactors
- Do not redesign systems that already exist unless explicitly requested
- Reuse existing managers, autoload singletons, configs, and helpers where possible
- Do not create parallel systems if an equivalent system already exists
- Do not rename files unless necessary
- Do not break existing scene paths
- Do not rename nodes, signals, public methods, exported properties, or autoload names unless necessary
- Avoid touching unrelated files
- Create missing files when needed
- Add comments only where logic is not obvious
- Keep code production-oriented, not demo hacks

## Godot-specific safety rules
- Keep scenes runnable in Godot 4
- Preserve existing node paths where possible
- If scene wiring changes are required, clearly explain the manual editor steps
- If exported variables, signals, or references are changed, explain the impact
- Do not silently change stage flow, save flow, unlock flow, drop flow, or equipment flow unless the task explicitly requires it

## Data-driven rules
Prefer configuration/data tables for:
- stage definitions
- wave definitions
- enemy spawn settings
- boss drops
- equipment stats
- unlock conditions

Avoid hardcoding progression or reward logic directly into unrelated scene scripts when an existing data/config pattern is available.

## Required workflow for every task
Before making code changes:
1. Inspect the current repo first
2. Find the existing implementation pattern related to the task
3. Summarize the relevant files and dependencies
4. List the exact files to create or modify
5. Only then apply changes

When implementing:
- Follow the current project structure
- Keep changes scoped to the requested feature
- Prefer the smallest working implementation
- Do not perform broad refactors unless explicitly requested

After implementing:
1. List all created/modified files
2. Explain how to run and verify the result
3. Call out any TODOs or manual Godot editor wiring
4. Mention any assumptions or uncertainties explicitly

## Current milestone
Build a playable vertical slice with:
1. Player movement
2. 8-direction shooting
3. One normal enemy
4. Boss 1-1
5. Stage clear flow
6. Equipment drop and equip
7. Hub and stage unlock

## Current development priority
- Keep 1-1 stable and playable
- Extend the project toward 1-2 to 1-6 using the same architecture
- Prefer reusable stage flow and reusable enemy/boss patterns
- Build features that can scale into later stages without rewriting the core loop