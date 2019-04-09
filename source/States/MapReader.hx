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

    public function read(filename : String) 
    {
        var jsonContents : String = Assets.getText("assets/maps/map.json");
        mapData = Json.parse(jsonContents);
    }

    public function color(value : String) : Int
    {
        var color : Int = 0xFF000000;

        if (value.charAt(0) == "#")
        {
            color = Std.parseInt("0xFF" + value.substr(1));
            trace("New color is " + color + " from " + "0xFF" + value.substr(1) +  " from " + value);
        }

        return color;
    }

    public function buildSolids(room : RoomData, world : World, solids : FlxGroup, oneways : FlxGroup /*, ladders*/) : Void
    {
        for (i in 0...room.solids.length) {
            switch (room.solids[i]) {
                case 1: // Solid
                    solids.add(new Solid(getSolidX(room, i)*7, getSolidY(room, i)*14, 7, 14, world));
                case 2: // Oneway
                    oneways.add(new Solid(getSolidX(room, i)*7, getSolidY(room, i)*14, 7, 4, world));
                case 3: // ladders!
                    // TODO: ladders
                default:
                    // Nop
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
    var gridX : Int;
    var gridY : Int;
}