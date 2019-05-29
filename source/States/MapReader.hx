package;

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

    public function read(mapName : String) 
    {
        var jsonContents : String = Assets.getText("assets/maps/" + mapName + ".json");
        mapData = Json.parse(jsonContents);
    }

    public function color(value : String) : Int
    {
        var color : Int = 0xFF000000;

        if (value.charAt(0) == "#")
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
            if (room.id == id)
                return room;
        }

        return null;
    }

    public function buildEntities(room : RoomData, world : World) : Void
    {
        if (room.actors != null)
        {
            for (actor in room.actors) {
                // trace("Actor " + actor);
                // TODO: Instantiate actors?
                // Check if they have to be created, using LRAM, WRAM
                switch (actor.type)
                {
                    case "spikes":
                        var spikes : Hazard = new Hazard(actor.x*7, actor.y*14, world, actor.type, actor.properties);
                        world.hazards.add(spikes);
                    default:
                        // nop
                }
            }
        }
    }

    public function findInitialRoom() : Int 
    {
        for (room in mapData.rooms) 
        {
            if (findActor(room, "spawn") != null)
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
    var properties : Map<String, String>;
}