package;

import flixel.FlxG;
@:allow(DebugSwitchesPanel)
class GameStatus
{
    public static var hudStyle : String;

    public static var playerGraphic : Int;
    public static var playerColor : Int;
    public static var map : String; 
    public static var room : Int;

    static var exits : Map<String, Bool>;
    static var switches : Map<String, Bool>;

    public static var maxHP : Int;
    public static var stars : Int;
    public static var redOrb : Bool;
    public static var blueOrb : Bool;
    public static var greenOrb : Bool;
    public static var yellowOrb : Bool;

    public static function Init()
    {
        var styles : Array<String> = ["simple", "skulls", "dragonquest"];
        hudStyle = styles[FlxG.random.int(0, styles.length-1)];
        playerGraphic = Math.random() > 0.5 ? 0 : 1;
        playerColor = Math.random() > 0.5 ? 0xFFbfce72 : 0xFF7d2140; // 0xFFfca0bf
        map = "desert";
        room = 1;

        maxHP = 5;

        stars = FlxG.random.int(0, 999);

        redOrb = blueOrb = greenOrb = yellowOrb = false;

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

    public static function getClearedExits() : Int
    {
        var counter : Int = 0;

        for (value in exits.iterator())
        {
            if (value)
                counter++;
        }

        return counter;
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
