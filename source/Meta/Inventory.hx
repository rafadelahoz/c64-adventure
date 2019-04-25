package;

import flixel.FlxG;

class Inventory 
{
    public static var MaxItems : Int = 11;
    public static var items : Array<ItemData>;
    public static var cursor : Int;

    public static function Init()
    {
        items = [];
        cursor = -1;
    }

    public static function Add(item : ItemData) : Bool
    {
        if (items.length < MaxItems)
        {
            items.push(item);
            return true;
        }
        else
            return false;
    }

    public static function MoveCursor()
    {
        if (items.length > 0)
        {
            if (cursor < 0)
                cursor = 0;
            else
                cursor = (cursor+1)%items.length;
        }
    }

    public static function GetCurrent()
    {
        if (cursor >= 0 && cursor < items.length)
        {
            return items[cursor];
        }

        return null;
    }

    public static function RemoveCurrent()
    {
        if (cursor >= 0 && cursor < items.length)
        {
            items.splice(cursor, 1);
        }
    }

    // Test purposes only!
    public static function Randomize()
    {
        var types : Array<String> = ["Mallet", "Cacti", "Dandelion", "Big dragon", "Jumpo", "Whatever", "Red potion", "Rock monster", "Skeleton", "Skele throw"];
        var type : String = null;

        items = [];
        while (items.length < FlxG.random.int(0, 11))
        {
            type = FlxG.random.getObject(types);
            items.push({
                type: type,
                label: type,
                id: null
            });
        }
    }
}

typedef ItemData = {
    var type : String;
    var label : String;
    var id : String;
    // other props?
}