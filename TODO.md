# TODO list

## Backlog

- Moving platforms
- Kill player
- Player hp?

- Navigating between rooms fails sometimes

- Gamestatus with
    - Switches map (boolean variables)
    - Variables map (multitype variables, string, numeric)

- Proper management of maps and their screens
    - Start point, exits...
- List of available maps for quick access (will be replaced by world map)
- Map properties: 
    - All entities are black
        - Or other color ==> all entities are white and get tinted in engine
    - Map name (display on top/bottom, or this is for rooms?)
- Gameplay loop
    - Player can get killed, restart the map, get kicked to world map

## Current

## Done

- Player color
- Ladders
    - [DONE] Don't work in bottom screens?
        - It was a map thing, just had to update world bounds
    - [DONE] Player can get stuck when they are surrounded by solids and he starts going down
        - When started to go down, player is not over layer and the current status is lost

## Descoped

- Why is the fg tilemap offset by 1px (only visually!)
    this is fucked, caused by flixel, openfl, rendering...
