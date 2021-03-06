package;

import Inventory.ItemData;

class LRAM
{
    static var roomItems : Map<String, Array<StoredItemData>>;
    public static var hp : Int;
    public static var inventoryOnEnter : Array<ItemData>;

    static var StateSwitch : Bool;

    static var OpenedLockSolids : Map<String, Bool>;
    static var SpawnedItems : Array<String>;
    
    static var World : World;

    public static function Init()
    {
        roomItems = new Map<String, Array<StoredItemData>>();
        hp = GameStatus.maxHP;
        OpenedLockSolids = new Map<String, Bool>();
        SpawnedItems = new Array<String>();
        StateSwitch = false;
    }

    public static function SetWorld(world : World)
    {
        World = world;
    }

    public static function StoreRoom(roomId : String, items : Array<StoredItemData>)
    {
        roomItems.set(roomId, items);
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

    public static function SwitchState()
    {
        StateSwitch = !StateSwitch;
        if (World != null)
            World.handleStateSwitchChange(StateSwitch);
    }

    public static function SetStateSwitch(on : Bool)
    {
        if (StateSwitch != on)
        {
            StateSwitch = on;
            if (World != null)
                World.handleStateSwitchChange(StateSwitch);
        }
    }

    public static function GetStateSwitch() : Bool
    {
        return StateSwitch;
    }
}

typedef StoredItemData = {
    var x : Float;
    var y : Float;
    var data : Inventory.ItemData;
};