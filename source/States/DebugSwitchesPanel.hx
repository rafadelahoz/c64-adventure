package;

import flixel.FlxSprite;
import text.PixelText;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup;

class DebugSwitchesPanel extends FlxSpriteGroup
{
    var switches : Array<FlxBitmapText>;
    var current : Int;

    public function new(X : Float, Y : Float)
    {
        super(X, Y);

        text(0, 0, "@=============@");

        switches = [];
        var char : Int = 1;
        var line : Int = 1;
        for (sw in GameStatus.switches.keys())
        {
            switches.push(text(char, line, sw));
            line++;
        }

        current = 0;
    }

    function text(char : Int, line : Int, text : String, ?color : Int = 0xFFFFFFFF) : FlxBitmapText
    {
        var object : FlxBitmapText = PixelText.New(char * 6, line * 6, text, color);
        addObject(object);
        return object;
    }

    function addObject(object : FlxSprite)
    {
        // object.cameras = [world.hudcam];
        object.scrollFactor.set(0, 0);
        add(object);
    }
}