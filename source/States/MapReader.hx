package;

import Teleport.TeleportData;
import flixel.group.FlxGroup;
import lime.utils.Assets;
import haxe.Json;

class MapReader
{
    // ??
    public var mapData : MapData;

    public function new()
    {
    }

    #if sys
    public function read(mapName : String)
    {
        var jsonContents : String = sys.io.File.getContent(MapListRoom.mapsDirectory + mapName + ".json");
        mapData = Json.parse(jsonContents);
    }
    #else
    public function read(mapName : String) 
    {
        var jsonContents : String = Assets.getText(MapListRoom.mapsDirectory + mapName + ".json");
        mapData = Json.parse(jsonContents);
    }
    #end

    public function color(value : String) : Int
    {
        var color : Int = 0xFF000000;

        if (value != null && value.length > 0 && value.charAt(0) == "#")
        {
            color = Std.parseInt("0xFF" + value.substr(1));
        }

        return color;
    }

    public function buildSolids(room : RoomData, world : World, solids : FlxGroup, oneways : FlxGroup, ladders : FlxGroup) : Void
    {
        for (i in 0...room.solids.length) {
            switch (room.solids[i]) {
                case 1: // Solid
                    solids.add(new Solid(getSolidX(room, i)*7, getSolidY(room, i)*14, 7, 14, world));
                case 2: // Oneway
                    oneways.add(new Solid(getSolidX(room, i)*7, getSolidY(room, i)*14, 7, 4, world));
                default:
                    // Nop
            }
        }

        for (col in 0...room.columns)
        {
            var row = 0;
            while (row < room.rows)
            {
                var i : Int = col + row*room.columns;
                if (room.solids[i] == 3)
                {
                    // Setup a new ladder
                    var lx = getSolidX(room, i)*7+2;
                    var ly = getSolidY(room, i)*14;
                    var lw = 3;
                    var lh = 0;
                    // Now for the height
                    while (row < room.rows && room.solids[col+row*room.columns] == 3)
                    {
                        row++;
                        lh += 14;
                    }

                    if (lh > 0)
                    {
                        // Add extra ladder for ladders leaving the screen from top and bottom
                        if (ly == 0)
                        {
                            ly -= 14;
                            lh += 14;
                        }
                        
                        if (ly + lh >= room.rows*14)
                            lh += 14;
                        
                        ladders.add(new Solid(lx, ly, lw, lh, world));
                        // Generate a oneway platform on top of the ladder
                        if (ly > 0) // unless it's at the top of the screen
                            oneways.add(new Solid(getSolidX(room, col+row*room.columns)*7, ly, 7, 4, world));
                    }
                }

                row++;
            }
        }
    }

    public function getSolidX(room : RoomData, index : Int) : Int
    {
        return (index % room.columns);
    }

    public function getSolidY(room : RoomData, index : Int) : Int
    {
        return Std.int(index / room.columns);
    }

    public function getRoom(id : Int) : RoomData
    {
        for (room in mapData.rooms)
        {
            if (room != null && room.id == id)
                return room;
        }

        return null;
    }

    public function buildEntities(room : RoomData, world : World) : Void
    {
        if (room.actors != null)
        {
            var processedActors : Map<String, Entity> = new Map<String, Entity>(); 
            var postProcessedActorsData : Array<ActorData> = [];

            for (actor in room.actors) {
                // Check if they have to be created, using LRAM, WRAM
                var x : Float = actor.x * Constants.TileWidth;
                var y : Float = actor.y * Constants.TileHeight;
                var w : Float = actor.w * Constants.TileWidth;
                var h : Float = actor.h * Constants.TileHeight;

                var properties : haxe.DynamicAccess<Dynamic> = actor.properties;

                var entity : Entity = null;

                switch (actor.type)
                {
                    case "exit":
                        var exit : MapExit = new MapExit(x, y, Constants.TileWidth, Constants.TileHeight, properties.get("name"), world);
                        world.exits.add(exit);
                        entity = exit;
                    case "spikes":
                        var spikes : Hazard = new StaticHazard(x, y, world, actor.type, actor.properties);
                        world.hazards.add(spikes);
                        entity = spikes;
                    case "pointy":
                        var pointy : Hazard = new StaticHazard(x, y, world, actor.type, actor.properties);
                        world.hazards.add(pointy);
                        entity = pointy;
                    case "falling-hazard":
                        var coconut : FallingHazard = new FallingHazard(x, y, world, actor.properties);
                        world.hazards.add(coconut);
                        entity = coconut;
                    case "enemy-plant":
                        var plant : EnemyPlant = new EnemyPlant(x, y, world, actor.properties);
                        world.enemies.add(plant);
                        entity = plant;
                    case "enemy-skeleton": 
                        var skeleton : EnemySkeleton = new EnemySkeleton(x, y, world, properties);
                        world.enemies.add(skeleton);
                        entity = skeleton;
                    case "enemy-frog":
                        var frog : EnemyFrog = new EnemyFrog(x, y, world, properties);
                        world.enemies.add(frog);
                        entity = frog;
                    case "item":
                        if (actor.properties != null)
                        {
                            // Items to be spawned once per level
                            if (!LRAM.IsItemSpawned(actor.id))
                            {
                                var properties : haxe.DynamicAccess<Dynamic> = actor.properties;
                                var type = properties.get("type");

                                var item : Item = new Item(x, y, world, {
                                    id: actor.id,
                                    type: type,
                                    label: type
                                });

                                world.items.add(item);
                                LRAM.HandleItemSpawn(actor.id);

                                entity = item;
                            }
                        }
                        else
                        {
                            trace("Item with no properties?");
                        }
                    case "key":
                        if (actor.properties != null)
                        {
                            // Items to be spawned once per level
                            if (!LRAM.IsItemSpawned(actor.id))
                            {
                                var properties : haxe.DynamicAccess<Dynamic> = actor.properties;
                                var flavour = properties.get("flavour");
                                var itemData : Inventory.ItemData = {
                                    id: actor.id,
                                    type: "KEY",
                                    label: (flavour == "NONE" ? "" : flavour + " ") + "KEY",
                                    properties: properties
                                };

                                var key : Item = new Item(x, y, world, itemData);
                                world.items.add(key);
                                LRAM.HandleItemSpawn(actor.id);

                                entity = key;
                            }
                        }
                    case "door":
                        var door : LockSolid = new LockSolid(x, y, w, h, world);
                        var flavour : String = "NONE";
                        var properties : haxe.DynamicAccess<Dynamic> = actor.properties;
                        if (properties != null)
                            flavour = properties.get("color");
                        door.init(actor.id, flavour);
                        world.solids.add(door);
                        entity = door;
                    case "teleport":
                        var visible : String = properties.get("visible");
                        if (visible == null)
                            visible = "false";
                        var color : Int = color(properties.get("color"));
                        var data : TeleportData = {
                            target: properties.get("target"),
                            tileX: properties.get("tileX"),
                            tileY: properties.get("tileY"),
                            visible: (visible == "true"),
                            color : color
                        };

                        var teleport : Teleport = new Teleport(x, y, w, h, data, world);
                        world.teleports.add(teleport);
                        entity = teleport;
                    case "falling": 
                        var color : Int = color(properties.get("color"));
                        var falling : FallingSolid = new FallingSolid(x, y, w, h, world);
                        falling.color = color;
                        if (properties.get("oneway"))
                            world.oneways.add(falling);
                        else
                            world.solids.add(falling);
                        entity = falling;
                    case "NPC":
                        var npc : NPC = new NPC(x, y, world, properties);
                        world.npcs.add(npc);
                        entity = npc;
                    case "solid":
                        var s : Solid = new Solid(x, y, w, h, world);
                        var c : String = properties.get("color");
                        if (c != null && c.length > 0)
                        {
                            s.color = color(c);
                            s.visible = true;
                        }
                        // TODO: Solid Graphic
                        world.solids.add(s);
                        entity = s;
                    case "puzzle-lever":
                        var lever : Lever = new Lever(x, y, world);
                        // TODO: Puzzle color
                        world.npcs.add(lever);
                        entity = lever;
                    case "puzzle-button":
                        var button : Button = new Button(x, y, world);
                        // TODO: Puzzle color
                        world.solids.add(button);
                        entity = button;
                    case "puzzle-switcher":
                        postProcessedActorsData.push(actor);
                    default:
                        // nop
                }

                if (entity != null)
                    processedActors.set(actor.id, entity);
            }

            for (actor in postProcessedActorsData)
            {
                // Check if they have to be created, using LRAM, WRAM
                var x : Float = actor.x * Constants.TileWidth;
                var y : Float = actor.y * Constants.TileHeight;
                var w : Float = actor.w * Constants.TileWidth;
                var h : Float = actor.h * Constants.TileHeight;

                var properties : haxe.DynamicAccess<Dynamic> = actor.properties;

                switch (actor.type)
                {
                    case "puzzle-switcher":
                        var target : Entity = processedActors.get(properties.get("target"));
                        if (target != null)
                        {
                            var switcher : EntitySwitcher = new EntitySwitcher(target);
                            world.add(switcher);
                        }
                        else
                        {
                            trace("Switcher[" + actor.id + "] refers to not found entity with id " + properties.get("target"));
                        }
                    default:
                        // NOP
                }
            }
        }
    }

    public function findInitialRoom() : Int 
    {
        for (room in mapData.rooms) 
        {
            if (room != null && findActor(room, "spawn") != null)
                return room.id;
        }

        return -1;
    }

    public function findActor(room : RoomData, type : String) : ActorData
    {
        if (room.actors != null)
        {
            for (actor in room.actors) {
                if (actor.type == type)
                    return actor;
            }
        }

        return null;
    }
}

typedef MapData = {
    var id : String;
    var name : String;
    var rooms : Array<RoomData>;
    var grid : Array<Null<Int>>;
    var size : {
        var x : Int;
        var y : Int;
    };
}

typedef RoomData = {
    var id : Int;
    var name : String;
    var colors : Array<String>;
    var columns : Int;
    var rows : Int;
    var tiles : {
        var bg: Array<Int>;
        var fg: Array<Int>;
    };
    var solids : Array<Int>;
    var actors : Array<ActorData>;
    var gridX : Int;
    var gridY : Int;
}

typedef ActorData = {
    var id : String;
    var x : Int;
    var y : Int;
    var type : String;
    var w : Int;
    var h : Int;
    var properties : Dynamic;
}