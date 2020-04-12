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
        cursor = 0;
    }

    public static function Put(item : ItemData) : Bool
    {
        if (cursor < 0)
            cursor = 0;
        if (GetCurrent() == null)
        {
            items[cursor] = item;
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
                cursor = (cursor+1)%MaxItems;
        }
    }

    public static function GetCurrent()
    {
        if (cursor >= 0 && cursor < MaxItems)
        {
            return items[cursor];
        }

        return null;
    }

    public static function RemoveCurrent()
    {
        if (cursor >= 0 && cursor < MaxItems)
        {
            items[cursor] = null;
        }
    }

    // Test purposes only!
    public static function Randomize()
    {
        // var types : Array<String> = ["Mallet", "Cacti", "Dandelion", "Big dragon", "Jumpo", "Whatever", "Red potion", "Rock monster", "Skeleton", "Skele throw"];
        var types : Array<String> = ["KEY", "APPLE", "DONUT", "STAR", "POTION", "POTION", "SHRIMP"];
        var type : String = null;

        items = [];
        items.push({type: "SHRIMP", label: "SHRIMP", id: null});
        items.push({type: "SHRIMP", label: "SHRIMP", id: null});
        while (items.length < FlxG.random.int(0, 11))
        {
            type = FlxG.random.getObject(types);
            items.push({
                type: type,
                label: type,
                id: null,
                properties: (type == "POTION" ? {"flavour": FlxG.random.int(5, 6)} : null)
            });
        }
    }

    public static function Backup() : Array<ItemData>
    {
        var copy : Array<ItemData> = [];

        for (item in items)
        {
            copy.push(clone(item));
        }

        return copy;
    }

    public static function Restore(backup : Array<ItemData>) : Void
    {
        items = backup;
    }

    static function clone(item : ItemData) : ItemData
    {
        return {
            type: item.type,
            label: item.label,
            id: item.id,
            properties: item.properties
        };
    }
}

typedef ItemData = {
    var type : String;
    var label : String;
    var id : String;
    // other props?
    var ?properties : Dynamic;
}