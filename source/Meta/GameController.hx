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
        FlxG.switchState(new World());
    }
}