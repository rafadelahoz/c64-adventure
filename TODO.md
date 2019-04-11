# TODO list

## Backlog

- Moving platforms
- Kill player
- Player hp?

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

- Ladders
    - Don't work in bottom screens?
        - Maybe a map thing
    - Player can get stuck when they are surrounded by solids and he starts going down

## Done

- Player color

## Descoped

- Why is the fg tilemap offset by 1px (only visually!)
    this is fucked, caused by flixel, openfl, rendering...
