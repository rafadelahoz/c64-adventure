package;

import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.FlxG;

class GameController
{
    public static function Init()
    {
        FlxG.scaleMode = new PixelPerfectScaleMode();
        FlxG.mouse.useSystemCursor = true;
        
        GameStatus.Init();
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

    public static function RestartMap()
    {
        // TODO: Keep inventory? Set it to initial?
        Inventory.Restore(LRAM.inventoryOnEnter);
        
        // TODO: Find hospital, checkpoint...? for that, avoid EnterMap
        EnterMap();
    }
}