package;

class GameStatus
{
    public static var playerGraphic : Int;
    public static var playerColor : Int;
    public static var map : String; 
    public static var room : Int;

    static var exits : Map<String, Bool>;
    static var switches : Map<String, Bool>;

    public static function Init()
    {
        playerGraphic = Math.random() > 0.5 ? 0 : 1;
        playerColor = Math.random() > 0.5 ? 0xFFbfce72 : 0xFF7d2140; // 0xFFfca0bf
        map = "desert";
        room = 1;

        exits = new Map<String, Bool>();
        switches = new Map<String, Bool>();

        Inventory.Init();
        Inventory.Randomize();
    }

    public static function isExitClear(exitName : String) : Bool
    {
        return exits.exists(exitName) && exits.get(exitName);
    }

    public static function setExitClear(exitName : String)
    {
        exits.set(exitName, true);
    }

    public static function getSwitch(name : String) : Bool
    {
        return switches.exists(name) && switches.get(name);
    }

    public static function setSwitch(name : String, value : Bool)
    {
        switches.set(name, value);
    }
}
