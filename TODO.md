# TODO list

## Backlog

- [DONE] ERR: Going down a ladder into a new screen makes carried item lost

- [DONE] Teleports between rooms
- [DONE] Moving platforms
- Kill player
    - Player touches something bad with no hp left
    - [DONE] Screen bg turns red, player and the killer entity are displayed only
    - [DONE] Wait for a sec, player dissappears in a cloud puff
    - [DONE] Options appear: "AGAIN" "TO MAP"
    - All items not present in the original inventory are lost
        - Generate all instances and make them bounce away from player!
- Player hp
    - [DONE] When player character is hit, it moves backwards considering contact point, and loses hp
        - [DONE] During this movement, no control is available
    - [DONE] A small period of invulnerability is granted, during which the player can move freely
    - Display HP

- On player death:
    - [DONE] Restart level or exit to map
    - Is inventory kept?
        - [NOPE] If we keep it and restart level, player may have items she shouldn't or even make the level unplayable? lost a key item?
        - If we don't keep it, it's safer, but player can only take things out of the level when properly leaving
            - More puzzle possibilities, maybe
                - Item to leave the level anywere without losing your items: useful for farming
        - In order to restart we need to 
            - [DONE] keep the original inventory in LRAM and restore it on restart-exit
            - Checkpoints have to store temporary inventory without overwriting the original one


- Hazards
    - [DONE] Basic: Damage player / kill directly

- Enemies
    - [DONE] Damage player
    - Have behaviours
        - [DONE] Walk around
        - Jump around

- Player using inventory
    - [DONE] Select current item with Select
    - Press B to use selected item
        - How?
            - World/Other entity knows what to instantiate and how
            - Items with special effects:
                - Mallet: used by player as weapon (method call on player)
            - Items that will act on world
                - [DONE] i.e. key on door
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


- Level RAM, world RAM
    - Enemies status to be kept
        - Until the player strays too far from the room? or always?
    - Items to be kept where they are placed until level is exited (on death they stay as well!)
        - Level RAM, initialized empty when entering the level 
            - Map of actor-id, room, position
    - Key items to be kept where they are placed even after leaving level
    - When a room is loaded,
        - for each instance in the map file
            - if it's not already in LRAM or WRAM, create it
        - check lram for instances in the current room and create them
        - check wram for instances in the current room and create them


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

- Map properties: 
    - (Room?) All entities are black
        - Or other color ==> all entities are white and get tinted in engine
    - [DONE] Map name (display on top/bottom)
    - [DONE] Room name

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

- [DONE] Maps and things
    - [DONE] List of available maps for quick access (will be replaced by world map)
    - [DONE] Maps to start in the spawn point
    - [DONE] Maps to have exits
        - [DONE] Exits are uniquely identified (mapid+exitid?)
        - [DONE] When used, they are "cleared"
            - [DONE] Array of exits and state (cleared, not) in GameStatus

- [DONE] Interaction between key and door
    - [DONE] Key is an item in the room
    - [DONE] Down to pick key
    - [DONE] Door is a block which can be opened
        - [DONE] It can be climbed an all, it's also a solid
    - [DONE] Key is an item in player inventory
    - [DONE] Player selects key using Select
    - [DONE] Press B to produce key
    - [DONE] Hold and move to carry it
        - [DONE] Player can walk (DONE), jump (DONE), climb (DONE), switch screens (DONE) while carrying
        - [DONE] On hit, stop carrying => !!may lead to lost key items!!
            - [!!!] Mechanism to summon key items for a price?
            - [!!!] Items can be lost all the same if the player drops them where they shouldn't
    - [DONE] Release to drop key

- Gameplay loop
    - [DONE] Player can get killed, restart the map, get kicked to world map


- [DONE] Pause effect for when things are happening
    - [DONE] Makes things look jankier
    - [DONE] Stop movement and all (not animations?) for 0.5s
    - [DONE] Play some fx for things dissapearing (i.e. cloud puff)
        - [DONE] Cloud puff to not be affected by pause

- [DONE] Alternate inventory
    - [DONE] Use Select to select the inventory slot (even if empty)
    - [DONE] B to interact with items
        - [DONE] When nothing is selected: pick up
        - [DONE] When something is selected: use it
    - [DONE] Hold B to WHEN USING hold whatever you are using
        - [DONE] Release to drop
        - [nope] OR Release to store again + Down to drop -> Can't climb
        - [nope] OR release quick to store, hold and release to carry and drop

## Descoped

- Why is the fg tilemap offset by 1px (only visually!)
    this is fucked, caused by flixel, openfl, rendering...
