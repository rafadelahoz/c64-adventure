package;

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
}

typedef MapData = {
    var id : String;
    var name : String;
    var rooms : Array<RoomData>;
    var grid : Array<Null<Int>>;
    var size : Map<String, Int>;
}

typedef RoomData = {
    var id : String;
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