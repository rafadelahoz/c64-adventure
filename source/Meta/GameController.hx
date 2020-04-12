package;

import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.FlxG;

class GameController
{
    public static function Init()
    {
        FlxG.scaleMode = new PixelPerfectScaleMode();
        #if (desktop || web)
        FlxG.mouse.useSystemCursor = true;
        #end
        
        GameStatus.Init();
    }

    public static function EnterWorldMap()
    {
        FlxG.switchState(new MapListRoom());
    }

    public static function SetCurrentMap(name : String)
    {
        GameStatus.map = name;
    }

    public static function EnterMap()
    {
        // Locate initial room using a MapReader
        var reader : MapReader = new MapReader();
        reader.read(GameStatus.map);
        GameStatus.room = reader.findInitialRoom();
        
        // TODO: Remove this after all maps have spawn point
        if (GameStatus.room < 0)
            GameStatus.room = 0;

        LRAM.Init();
        LRAM.inventoryOnEnter = Inventory.Backup();

        FlxG.switchState(new World());
    }

    public static function ClearMap(exitName : String)
    {
        if (!GameStatus.isExitClear(exitName)) 
        {
            GameStatus.setExitClear(exitName);
        }

        /* TODO: You probably want to provide the exit name to the world
           map somehow in order to play some effect or whatever */
        // EnterWorldMap();
    }

    public static function RestartMap()
    {
        // Set inventory to initial
        Inventory.Restore(LRAM.inventoryOnEnter);
        
        // TODO: Find hospital, checkpoint...? for that, avoid EnterMap
        EnterMap();
    }

    public static function AbandonMap()
    {
        Inventory.Restore(LRAM.inventoryOnEnter);
        EnterWorldMap();
    }
}