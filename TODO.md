# TODO list

## Backlog

- Teleports between rooms
- [?] Moving platforms
- Kill player
    - Player touches something bad with no hp left
    - Screen bg turns red, player and the killer entity are displayed only
    - Wait for a sec, player dissappears in a cloud puff
    - Options appear: "AGAIN" "TO MAP"
- Player hp?

- Player using inventory
    - [DONE] Select current item with Select
    - Press B to use selected item
        - How?
            - World/Other entity knows what to instantiate and how
            - Items with special effects:
                - Mallet: used by player as weapon (method call on player)
            - Items that will act on world
                - i.e. key on door
                - Seed: placed by player on ground
                    When on contact with soil, it will get planted
                    A vine will grow then
            - Generic use: drop item with graphic
                - [DONE] Keep pressing B to carry item
                - [DONE] Will be dropped on release
                - Player to play animation
                    - [DONE] Changes player state
                    - [DONE] Can be aborted by player (because of state, ask first!)
                - Generate "item" entity with type, id, other props
                    - Graphic to be extracted given type?
                        - Item database



- Pause effect for when things are happening
    - Makes things look jankier
    - Stop movement and all (not animations?) for 0.5s
    - Play some fx for things dissapearing (i.e. cloud puff)

- ? Alternate inventory
    - Use Select to select the inventory slot (even if empty)
    - B to interact with items
        - When nothing is selected: pick up
        - When something is selected: use it
    - Hold B to hold whatever you are using
        - Release to (pick if picking, drop if dropping)
        - OR Release to store again + Down to drop -> Can't climb
        - [THIS?] OR release quick to store, hold and release to carry and drop

- Level RAM, world RAM
    - Items to be kept where they are placed until level is exited (on death they stay as well!)
        - Level RAM, initialized empty when entering the level 
            - Map of actor-id, room, position
    - Key items to be kept where they are placed even after leaving level
    - When a room is loaded,
        - for each instance in the map file
            - if it's not already in LRAM or WRAM, create it
        - check lram for instances in the current room and create them
        - check wram for instances in the current room and create them

- Interaction between key and door
    - Key is an item in the room
    - Down to pick key
    - Door is a block which can be opened
        - It can be climbed an all, it's also a solid
    - Key is an item in player inventory
    - Player selects key using Select
    - Press B to produce key
    - Hold and move to carry it
        - Player can walk (DONE), jump (DONE), climb (DONE), switch screens (DONE) while carrying
        - On hit, stop carrying => !!may lead to lost key items!!
            - Mechanism to summon key items for a price?
            - Items can be lost all the same if the player drops them where they shouldn't
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
    - LRAM with switches for the current map only?

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

### Maybe not

- [???] Player carries things
    - ? Things to have body
        - Can't go through walls with them -> Can't climb!
        - Increase player width while carrying
        - When picking up

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
- [FIXED] Navigating between rooms fails sometimes
- [FIXED] Player releasing item fails on the end of 1 tile high tunnels
- [DONE] Player picks things
    - [DONE] Press down while over it to put it in inventory directly
- [DONE] Don't drop things outside the room area

## Descoped

- Why is the fg tilemap offset by 1px (only visually!)
    this is fucked, caused by flixel, openfl, rendering...
