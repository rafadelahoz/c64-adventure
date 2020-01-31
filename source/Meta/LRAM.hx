package;

import Inventory.ItemData;

class LRAM
{
    static var roomItems : Map<String, Array<StoredItemData>>;
    public static var hp : Int;
    public static var inventoryOnEnter : Array<ItemData>;

    static var OpenedLockSolids : Map<String, Bool>;
    static var SpawnedItems : Array<String>;

    public static function Init()
    {
        roomItems = new Map<String, Array<StoredItemData>>();
        hp = 3;
        OpenedLockSolids = new Map<String, Bool>();
        SpawnedItems = new Array<String>();
    }

    public static function StoreRoom(roomId : String, items : Array<StoredItemData>)
    {
        roomItems.set(roomId, items);
        trace(roomItems);
    }

    public static function GetRoom(roomId : String) : Array<StoredItemData>
    {
        return roomItems.get(roomId);
    }

    public static function OpenLockSolid(id : String, ?open : Bool = true)
    {
        OpenedLockSolids.set(id, open);
    }

    public static function IsLockSolidOpen(id : String) : Bool
    {
        return (OpenedLockSolids.exists(id) && OpenedLockSolids.get(id) == true);
    }

    public static function IsItemSpawned(id : String) : Bool
    {
        return (SpawnedItems.indexOf(id) > -1);
    }

    public static function HandleItemSpawn(id : String)
    {
        SpawnedItems.push(id);
    }
}

typedef StoredItemData = {
    var x : Float;
    var y : Float;
    var data : Inventory.ItemData;
};