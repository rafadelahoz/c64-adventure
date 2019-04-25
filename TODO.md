# TODO list

## Backlog

- Teleports between rooms
- [?] Moving platforms
- Kill player
- Player hp?

- Player picks things
    - Press down while over it to put it in inventory directly

- Player using inventory
    - [DONE] Select current item with Select
    - Press B to use selected item
        - How?
            - World/Other entity knows what to instantiate and how
            - Mallet: used by player as weapon (method call on player)
            - Seed: placed by player on ground
                When on contact with soil, it will get planted
                A vine will grow then
            - ? Keep pressing B to carry item
                Will be dropped on release
                Item will act on world
                    - i.e. key on door
            - Generic: drop item with graphic
                - Player to play animation
                    - Changes player state
                    - Can be aborted by player (because of state, ask first!)
                - Generate "item" entity with type, id, other props
                    - Graphic to be extracted given type?

- Interaction between key and door
    - Key is an item in the room
    - Down to pick key
    - Door is a block which can be opened
        - It can be climbed an all, it's also a solid
    - Key is an item in player inventory
    - Player selects key using Select
    - Press B to produce key
    - Hold and move to carry it
        - Player can walk, jump, climb??, switch screens? while carrying
        - On hit, stop carrying => !!may lead to lost key items!!
            - Mechanism to summon key items for a price?
    - Release to drop key

- NPCs
    - Actors with
        - a graphic (animation?)
            - Database of animations managed by editor
                - Select graphic, frames, speed (manually!)
        - scripts pages (rm2k style)
            - lists of actions
                - messages "HELLO", "THIS IS ANOTHER MESSAGE"
                - wait (X secs)
                - instantiate something at (relative?) position
                - set switch or variable
            - with conditions
                - no condition (only if no other list happens)
                - switch on/off
                - variable?
                - GameStatus checks?

- Dialogues!

- Gamestatus with
    - Switches map (boolean variables)
    - Variables map (multitype variables, string, numeric)

- Maps and things
    - List of available maps for quick access (will be replaced by world map)
    - [DONE] Maps to start in the spawn point
    - Maps to have exits
        - Exits are uniquely identified (mapid+exitid?)
        - When used, they are "cleared"
            - Array of exits and state (cleared, not) in GameStatus

- Map properties: 
    - (Room?) All entities are black
        - Or other color ==> all entities are white and get tinted in engine
    - Map name (display on top/bottom, or this is for rooms?)
    
- Gameplay loop
    - Player can get killed, restart the map, get kicked to world map

- Game start:
    - Customize player (name, sprite, color)

## Current

## Done

- Player color
- Ladders
    - [DONE] Don't work in bottom screens?
        - It was a map thing, just had to update world bounds
    - [DONE] Player can get stuck when they are surrounded by solids and he starts going down
        - When started to go down, player is not over layer and the current status is lost
- Navigating between rooms fails sometimes
    - Signs were inverted
- [ERR] Navigating between rooms fails sometimes

## Descoped

- Why is the fg tilemap offset by 1px (only visually!)
    this is fucked, caused by flixel, openfl, rendering...
