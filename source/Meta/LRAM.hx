package;

import Inventory.ItemData;

class LRAM
{
    static var roomItems : Map<String, Array<StoredItemData>>;
    public static var hp : Int;
    public static var inventoryOnEnter : Array<ItemData>;

    public static function Init()
    {
        roomItems = new Map<String, Array<StoredItemData>>();
        hp = 3;
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
}

typedef StoredItemData = {
    var x : Float;
    var y : Float;
    var data : Inventory.ItemData;
};